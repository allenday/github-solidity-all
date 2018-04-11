pragma solidity ^0.4.11;

/**
 * @Name CRN (CareerXon) Token
 *
 * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20 with the addition 
 * of ownership, a lock and issuing.
 *
 * #created 08/20/2017
 */

import './StandardToken.sol';
import './Ownable.sol';
import './mint.sol';


contract CareerXonToken is StandardToken, Ownable, MintableToken{
    string public constant name = "CareerXon";
    string public constant symbol = "CRN";
    uint public constant decimals = 18;
    string public standard = "Token 0.1";
    int256 public maxSupply = 1500000000000000000000000;
    //15,000,000 CareerXon tokens max supply

    using SafeMath for uint256;

    // timestamps for first presale and ICO
    uint public startPreSale;
    uint public endPreSale;
    uint public startICO;
    uint public endICO;



    // how many token units a buyer gets per wei
    uint256 public rate;

    uint256 public minTransactionAmount;

    uint256 public raisedForEther = 0;

    modifier inActivePeriod() {
        require((startPreSale < now && now <= endPreSale) || (startICO < now && now <= endICO));
        _;
    }

    function CareerXonToken(uint _startP, uint _endP, uint _startI, uint _endI) {
        require(_startP < _endP);
        require(_startI < _endI);
        

        //12,900,000 for eth supply
        //2,000,000 for bitcoin and bitcoin cash sales supply minted
        //100,000 for bounty and transalation minted
        //After all these distribution, Remaining minted coins will be burned.
        totalSupply = 12900000000000000000000000;


        // 1 ETH = 1300 CareerXon
        rate = 1300;

        // minimal invest 0.01 ETH
        minTransactionAmount = 0.01 ether;

        startPreSale = _startP;
        endPreSale = _endP;
        startICO = _startI;
        endICO = _endI;
        transferlocked = true;
        // wallet withdrawal lock for protection
        wallocked = true;

    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setupPeriodForPreSale(uint _start, uint _end) onlyOwner {
        require(_start < _end);
        startPreSale = _start;
        endPreSale = _end;
    }

    function setupPeriodForICO(uint _start, uint _end) onlyOwner {
        require(_start < _end);
        startICO = _start;
        endICO = _end;
    }

    // fallback function can be used to buy tokens
    function () inActivePeriod payable {
        buyTokens(msg.sender);
    }

    // token auto purchase function
    function buyTokens(address _sender) inActivePeriod payable {
        require(_sender != 0x0);
        require(msg.value >= minTransactionAmount);

        uint256 weiAmount = msg.value;

        raisedForEther = raisedForEther.add(weiAmount);

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        tokens += getBonus(tokens);

        tokenReserved(_sender, tokens);

    }
    
    function withdraw(uint256 _value) onlyOwner returns (bool){
        if (wallocked) {
            throw;
        }
        owner.transfer(_value);
        return true;
    }
    function walunlock() onlyOwner returns (bool success)  {
        wallocked = false;
        return true;
    }
    function wallock() onlyOwner returns (bool success)  {
        wallocked = true;
        return true;
    }

    /*
    *    PreSale:
    *        Day 1: +33% bonus
    *        Day 2: +20% bonus
    *        Day 3: +10% bonus
    *        Day 4: +5% bonus
    *        Day 5 & onwards: No bonuses
    */
    function getBonus(uint256 _tokens) constant returns (uint256 bonus) {
        require(_tokens != 0);
        if (1 == getCurrentPeriod()) {
            if (startPreSale <= now && now < startPreSale + 1 days) {
                return _tokens.div(3);
            } else if (startPreSale + 1 days <= now && now < startPreSale + 2 days ) {
                return _tokens.div(5);
            } else if (startPreSale + 2 days <= now && now < startPreSale + 3 days ) {
                return _tokens.div(10);
            }else if (startPreSale + 3 days <= now && now < startPreSale + 4 days ) {
                return _tokens.mul(5).div(100);
            }
        }
        
        return 0;
        
    /*
    *    ICO:
    *        Day 1: +20% bonus
    *        Day 2: +10% bonus
    *        Day 3: +5% bonus
    *        Day 4 & onwards: No bonuses
    */
        if (2 == getCurrentPeriod()) {
            if (startICO <= now && now < startICO + 1 days) {
                return _tokens.div(5);
            } else if (startICO + 1 days <= now && now < startICO + 2 days ) {
                return _tokens.div(10);
            } else if (startICO + 2 days <= now && now < startICO + 3 days ) {
                return _tokens.mul(5).div(100);
            }
        }

        return 0;
    }

    //start date & end date of presale and future ICO
    function getCurrentPeriod() inActivePeriod constant returns (uint){
        if ((startPreSale < now && now <= endPreSale)) {
            return 1;
        } else if ((startICO < now && now <= endICO)) {
            return 2;
        } else {
            return 0;
        }
    }

    function tokenReserved(address _to, uint256 _value) internal returns (bool) {
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    // token transfer lock. Unlock at end of Presale,ICO
    
    function transferunlock() onlyOwner returns (bool success)  {
        transferlocked = false;
        return true;
    }
    function transferlock() onlyOwner returns (bool success)  {
        transferlocked = true;
        return true;
    }
}