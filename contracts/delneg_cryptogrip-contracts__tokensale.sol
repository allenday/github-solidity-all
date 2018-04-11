pragma solidity ^0.4.13;


import 'http://github.com/OpenZeppelin/zeppelin-solidity/contracts/token/StandardToken.sol';
import 'http://github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol';


/////////////////////////////////////////////////////////
//////////////// Token contract start////////////////////
/////////////////////////////////////////////////////////

contract CryptoGripInitiative is StandardToken, Ownable {
    string  public  constant name = "Crypto Grip Initiative";

    string  public  constant symbol = "CGI";

    uint    public  constant decimals = 18;

    uint    public  saleStartTime;

    uint    public  saleEndTime;

    address public  tokenSaleContract;

    modifier onlyWhenTransferEnabled() {
        if (now <= saleEndTime && now >= saleStartTime) {
            require(msg.sender == tokenSaleContract || msg.sender == owner);
        }
        _;
    }

    modifier validDestination(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function CryptoGripInitiative(uint tokenTotalAmount, uint startTime, uint endTime, address admin) {
        // Mint all tokens. Then disable minting forever.
        balances[msg.sender] = tokenTotalAmount;
        totalSupply = tokenTotalAmount;
        Transfer(address(0x0), msg.sender, tokenTotalAmount);

        saleStartTime = startTime;
        saleEndTime = endTime;

        tokenSaleContract = msg.sender;
        transferOwnership(admin);
        // admin could drain tokens that were sent here by mistake
    }

    function transfer(address _to, uint _value)
    onlyWhenTransferEnabled
    validDestination(_to)
    returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value)
    onlyWhenTransferEnabled
    validDestination(_to)
    returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    event Burn(address indexed _burner, uint _value);

    function burn(uint _value) onlyWhenTransferEnabled
    returns (bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    //    // save some gas by making only one contract call
    //    function burnFrom(address _from, uint256 _value) onlyWhenTransferEnabled
    //    returns (bool) {
    //        assert(transferFrom(_from, msg.sender, _value));
    //        return burn(_value);
    //    }

    function emergencyERC20Drain(ERC20 token, uint amount) onlyOwner {
        token.transfer(owner, amount);
    }
}


/////////////////////////////////////////////////////////
/////////////// Whitelist contract start/////////////////
/////////////////////////////////////////////////////////


contract Whitelist {
    address public owner;

    address public sale;

    mapping (address => uint) public accepted;

    function Whitelist(address _owner, address _sale) {
        owner = _owner;
        sale = _sale;
    }

    function accept(address a, uint amountInWei) {
        assert(msg.sender == owner || msg.sender == sale);

        accepted[a] = amountInWei * 10 ** 18;
    }

    function setSale(address sale_) {
        assert(msg.sender == owner);

        sale = sale_;
    }

    function getCap(address _user) constant returns (uint) {
        uint cap = accepted[_user];
        return cap;
    }
}


/////////////////////////////////////////////////////////
///////// Contributor Approver contract start////////////
/////////////////////////////////////////////////////////

contract ContributorApprover {
    Whitelist public list;

    mapping (address => uint)    public participated;

    uint public presaleStartTime;

    uint public remainingPresaleCap;

    uint public remainingPublicSaleCap;

    uint                      public openSaleStartTime;

    uint                      public openSaleEndTime;

    using SafeMath for uint;


    function ContributorApprover(
    Whitelist _whitelistContract,
    uint preIcoCap,
    uint IcoCap,
    uint _presaleStartTime,
    uint _openSaleStartTime,
    uint _openSaleEndTime) {
        list = _whitelistContract;
        openSaleStartTime = _openSaleStartTime;
        openSaleEndTime = _openSaleEndTime;
        presaleStartTime = _presaleStartTime;
        remainingPresaleCap = preIcoCap * 10 ** 18;
        remainingPublicSaleCap = IcoCap * 10 ** 18;

        //    Check that presale is earlier than opensale
        require(presaleStartTime < openSaleStartTime);
        //    Check that open sale start is earlier than end
        require(openSaleStartTime < openSaleEndTime);
    }

    // this is a seperate function so user could query it before crowdsale starts
    function contributorCap(address contributor) constant returns (uint) {
        return list.getCap(contributor);
    }

    function eligible(address contributor, uint amountInWei) constant returns (uint) {
        //        Presale not started yet
        if (now < presaleStartTime) return 0;
        //    Both presale and public sale have ended
        if (now >= openSaleEndTime) return 0;

        //        Presale
        if (now < openSaleStartTime) {
            //        Presale cap limit reached
            if (remainingPresaleCap <= 0) {
                return 0;
            }
            //            Get initial cap
            uint cap = contributorCap(contributor);
            // Account for already invested amount
            uint remainedCap = cap.sub(participated[contributor]);
            //        Presale cap almost reached
            if (remainedCap > remainingPresaleCap) {
                remainedCap = remainingPresaleCap;
            }
            //            Remaining cap is bigger than contribution
            if (remainedCap > amountInWei) return amountInWei;
            //            Remaining cap is smaller than contribution
            else return remainedCap;
        }
        //        Public sale
        else {
            //           Public sale  cap limit reached
            if (remainingPublicSaleCap <= 0) {
                return 0;
            }
            //            Public sale cap almost reached
            if (amountInWei > remainingPublicSaleCap) {
                return remainingPublicSaleCap;
            }
            //            Public sale cap is bigger than contribution
            else {
                return amountInWei;
            }
        }
    }

    function eligibleTestAndIncrement(address contributor, uint amountInWei) internal returns (uint) {
        uint result = eligible(contributor, amountInWei);
        participated[contributor] = participated[contributor].add(result);
        //    Presale
        if (now < openSaleStartTime) {
            //        Decrement presale cap
            remainingPresaleCap = remainingPresaleCap.sub(result);
        }
        //        Publicsale
        else {
            //        Decrement publicsale cap
            remainingPublicSaleCap = remainingPublicSaleCap.sub(result);
        }

        return result;
    }

    function saleEnded() constant returns (bool) {
        return now > openSaleEndTime;
    }

    function saleStarted() constant returns (bool) {
        return now >= presaleStartTime;
    }

    function publicSaleStarted() constant returns (bool) {
        return now >= openSaleStartTime;
    }
}


/////////////////////////////////////////////////////////
///////// Token Sale contract start /////////////////////
/////////////////////////////////////////////////////////

contract CryptoGripTokenSale is ContributorApprover {
    uint    public  constant tokensPerEthPresale = 1055;

    uint    public  constant tokensPerEthPublicSale = 755;

    address             public admin;

    address             public gripWallet;

    CryptoGripInitiative public token;

    uint                public raisedWei;

    bool                public haltSale;

    function CryptoGripTokenSale(address _admin,
    address _gripWallet,
    Whitelist _whiteListContract,
    uint _totalTokenSupply,
    uint _premintedTokenSupply,
    uint _presaleStartTime,
    uint _publicSaleStartTime,
    uint _publicSaleEndTime,
    uint _presaleCap,
    uint _publicSaleCap)

    ContributorApprover(_whiteListContract,
    _presaleCap,
    _publicSaleCap,
    _presaleStartTime,
    _publicSaleStartTime,
    _publicSaleEndTime)
    {
        admin = _admin;
        gripWallet = _gripWallet;

        token = new CryptoGripInitiative(_totalTokenSupply * 10 ** 18, _presaleStartTime, _publicSaleEndTime, _admin);

        // transfer preminted tokens to company wallet
        token.transfer(gripWallet, _premintedTokenSupply * 10 ** 18);
    }

    function setHaltSale(bool halt) {
        require(msg.sender == admin);
        haltSale = halt;
    }

    function() payable {
        buy(msg.sender);
    }

    event Buy(address _buyer, uint _tokens, uint _payedWei);

    function buy(address recipient) payable returns (uint){
        require(tx.gasprice <= 50000000000 wei);

        require(!haltSale);
        require(saleStarted());
        require(!saleEnded());

        uint weiPayment = eligibleTestAndIncrement(recipient, msg.value);

        require(weiPayment > 0);

        // send to msg.sender, not to recipient
        if (msg.value > weiPayment) {
            msg.sender.transfer(msg.value.sub(weiPayment));
        }

        // send payment to wallet
        sendETHToMultiSig(weiPayment);
        raisedWei = raisedWei.add(weiPayment);

        uint recievedTokens = 0;

        if (now < openSaleStartTime) {
            recievedTokens = weiPayment.mul(tokensPerEthPresale);
        }
        else {
            recievedTokens = weiPayment.mul(tokensPerEthPublicSale);
        }

        assert(token.transfer(recipient, recievedTokens));


        Buy(recipient, recievedTokens, weiPayment);

        return weiPayment;
    }

    function sendETHToMultiSig(uint value) internal {
        gripWallet.transfer(value);
    }

    event FinalizeSale();
    // function is callable by everyone
    function finalizeSale() {
        require(saleEnded());
        require(msg.sender == admin);

        // burn remaining tokens
        token.burn(token.balanceOf(this));

        FinalizeSale();
    }

    // ETH balance is always expected to be 0.
    // but in case something went wrong, we use this function to extract the eth.
    function emergencyDrain(ERC20 anyToken) returns (bool){
        require(msg.sender == admin);
        require(saleEnded());

        if (this.balance > 0) {
            sendETHToMultiSig(this.balance);
        }

        if (anyToken != address(0x0)) {
            assert(anyToken.transfer(gripWallet, anyToken.balanceOf(this)));
        }

        return true;
    }

    // just to check that funds goes to the right place
    // tokens are not given in return
    function debugBuy() payable {
        require(msg.value == 123);
        sendETHToMultiSig(msg.value);
    }
}