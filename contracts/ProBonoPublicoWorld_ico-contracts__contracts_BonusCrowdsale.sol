pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * Crowdsale that implements bonuses by temporarily overriding
 * rate at the time of the purchase.
 */
contract BonusCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 bonusRate;
    uint256 expiration;

    function BonusCrowdsale(
        uint256 bonusRate_,
        uint256 expiration_
    ) public {
        bonusRate = bonusRate_;
        expiration = expiration_;
    }

    function buyTokens(address beneficiary) public payable {
        if (now <= expiration) { // If the rate is different currently
            uint256 rate_ = rate; // Store rate
            rate = bonusRate;
            super.buyTokens(beneficiary);
            rate = rate_; // Restore rate
        } else {
            super.buyTokens(beneficiary);
        }
    }
}
