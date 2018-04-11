pragma solidity ^0.4.17;

import "ds-token/token.sol";
import "ds-auth/auth.sol";
import "ds-math/math.sol";
import "ds-note/note.sol";
import "ds-stop/stop.sol";

contract StandardSale is DSNote, DSStop, DSMath {

    DSToken public token;

    uint public total;
    uint public forSale;

    uint public cap;
    uint public softCap;

    uint public timeLimit;
    uint public softCapTimeLimit;
    uint public startTime;
    uint public endTime;

    address public multisig;

    uint public rate; // Token per ETH
    uint public collected;

    function StandardSale(
        bytes32 symbol, 
        uint total_, 
        uint forSale_, 
        uint cap_,
        uint softCap_, 
        uint timeLimit_, 
        uint softCapTimeLimit_,
        uint startTime_,
        address multisig_) public {

        token = new DSToken(symbol);

        total = total_;
        forSale = forSale_;
        cap = cap_;
        softCap = softCap_;
        timeLimit = timeLimit_;
        softCapTimeLimit = softCapTimeLimit_;
        startTime = startTime_;
        endTime = startTime + timeLimit;

        multisig = multisig_;

        rate = wdiv(forSale, cap);

        token.mint(total);
        token.push(multisig, sub(total, forSale));
        token.stop();
    }

    function time() internal returns (uint) {
        return block.timestamp;
    }

    // can't postpone after sale has started
    function postpone(uint startTime_) public auth {
        require(time() < startTime);
        startTime = startTime_;
        endTime = startTime + timeLimit;
    }

    function buy(uint price, address who, uint val, bool send) internal {
        
        /**********************
            ETH Refund Logic
        ***********************/

        uint requested = wmul(val, price);
        uint keep = val;

        if (requested > token.balanceOf(this)) {
            requested = token.balanceOf(this);
            keep = wdiv(requested, price);
        }

        // return excess ETH to the user
        uint refund = sub(val, keep);
        if(refund > 0 && send) {
            who.transfer(refund); // .transfer doesn't forward enough gas for re-entrancy attack
        }


        /*********************
            Asset Transfers
        **********************/

        token.start();
        token.push(who, requested);
        token.stop();

        if (send) {
            multisig.transfer(keep); // send collected ETH to multisig
        }


        /********************
            End Time Logic
        *********************/

        if (token.balanceOf(this) == 0) {
            endTime = time();
        } else if (collected < softCap && add(collected, keep) >= softCap) {
            // because you can hit softCap before sale starts
            var x = time() >= startTime ? time() : startTime;
            endTime =  x + softCapTimeLimit;
        }

        collected = add(collected, keep);

    }

    function() public payable stoppable note {

        require(time() >= startTime && time() < endTime);
        buy(rate, msg.sender, msg.value, true);
    }

    function finalize() public auth {
        require(time() >= endTime);

        // enable transfer
        token.start();

        // transfer undistributed Token
        token.push(multisig, token.balanceOf(this));

        // owner -> multisig
        token.setOwner(multisig);
    }

    // because sometimes people get a little too excited and send the wrong token
    function transferTokens(address tkn_, address dst, uint wad) public auth {
        ERC20 tkn = ERC20(tkn_);
        tkn.transfer(dst, wad);
    }
}


contract TwoStageSale is StandardSale {

    mapping (address => bool) public presale;

    struct Tranch {
        uint floor;
        uint rate;
    }

    Tranch[] public tranches;

    uint public presaleStartTime;
    uint public preSaleCap;
    uint public preCollected;

    function TwoStageSale(
        bytes32 symbol, 
        uint total_, 
        uint forSale_, 
        uint cap_, 
        uint softCap_, 
        uint timeLimit_, 
        uint softCapTimeLimit_,
        uint startTime_,
        address multisig_,
        uint presaleStartTime_,
        uint initPresaleRate,
        uint preSaleCap_) 
    StandardSale(
        symbol, 
        total_, 
        forSale_, 
        cap_, 
        softCap_, 
        timeLimit_, 
        softCapTimeLimit_,
        startTime_,
        multisig_) public {
        
        tranches.push(Tranch(0, initPresaleRate));

        require(presaleStartTime_ < startTime_);
        presaleStartTime = presaleStartTime_;

        preSaleCap = preSaleCap_;
    }

    function setPresale(address who, bool what) public auth {
        presale[who] = what;
    }

    // can't set startTime after presale has started
    function postpone(uint startTime_) public auth {
        require(time() < presaleStartTime);
        require(startTime < startTime_); // can only postpone. for simplicity
        startTime = startTime_;
        endTime = startTime + timeLimit;
    }

    // because some times operators pre-pre-sell their token
    function preDistribute(address who, uint val) public auth {
        require(time() < presaleStartTime);
        require(add(preCollected, val) <= preSaleCap);
        preBuy(who, val, false);
    }

    function appendTranch(uint floor_, uint rate_) public auth {
        require(tranches[tranches.length - 1].floor < floor_);
        tranches.push(Tranch(floor_, rate_));
    }

    function preBuy(address who, uint val, bool send) internal {
        

        /**********************
            ETH Refund Logic
        ***********************/

        uint keep = val;
        if (add(keep, preCollected) > preSaleCap) {
            keep = sub(preSaleCap, preCollected);
        }

        // return excess ETH to the user
        uint refund = sub(val, keep);
        if(refund > 0 && send) {
            who.transfer(refund);
        }

        preCollected = add(preCollected, keep);


        /*************************
            Pre-sale Rate Logic
        **************************/


        for (uint id = 0; id < tranches.length; id++) {
            
            if (id + 1 == tranches.length) {
                break;
            } else if (tranches[id].floor == keep) {
                break;
            } else if (tranches[id + 1].floor > keep) {
                break;
            }
        }

        uint presaleRate = tranches[id].rate;

        buy(presaleRate, who, keep, send);
    }

    function() public payable stoppable note {

        require(time() >= presaleStartTime && time() < endTime);

        if (time() < startTime) {
            require(presale[msg.sender]);
            preBuy(msg.sender, msg.value, true);
        } else {
            buy(rate, msg.sender, msg.value, true);
        }

    }
}
