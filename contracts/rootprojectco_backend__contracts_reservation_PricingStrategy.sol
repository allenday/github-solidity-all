pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract PricingStrategy {

    using SafeMath for uint;

    uint public newRateTime;
    uint public rate1;
    uint public rate2;
    uint public minimumWeiAmount;

    function PricingStrategy(
        uint _newRateTime,
        uint _rate1,
        uint _rate2,
        uint _minimumWeiAmount
    ) {
        require(_newRateTime > 0);
        require(_rate1 > 0);
        require(_rate2 > 0);
        require(_minimumWeiAmount > 0);

        newRateTime = _newRateTime;
        rate1 = _rate1;
        rate2 = _rate2;
        minimumWeiAmount = _minimumWeiAmount;
    }

    /** Interface declaration. */
    function isPricingStrategy() public constant returns (bool) {
        return true;
    }

    /** Calculate the current price for buy in amount. */
    function calculateTokenAmount(uint weiAmount) public constant returns (uint tokenAmount) {
        uint bonusRate = 0;

        if (weiAmount >= minimumWeiAmount) {
            if (now < newRateTime) {
                bonusRate = rate1;
            } else {
                bonusRate = rate2;
            }
        }

        return weiAmount.mul(bonusRate);
    }
}