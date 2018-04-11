pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * Crowdsale that implements bonuses by temporarily overriding
 * rate at the time of the purchase.
 * The technique relies on using a multiplied rate for two reasons:
 * a) clarity b) to simplify fallback to default rate
 *
 * 1. Should give time based bonuses
 * 2. Should give value based bonus
 * 3. These bonuses stack multiplicatively
 * 4. There are no rounding errors when rate is X * 10'000
 */
contract MultiBonusCrowdsale is Crowdsale {
    using SafeMath for uint256;

    struct Bonuses {
        uint256 bonusRate; // in percent
        uint256 expiration;
    }

    // Bonuses in first-last chronological order, expiration is cumulative
    Bonuses[5] public BONUSES;

    function MultiBonusCrowdsale() public {
        // Unfortunately struct[] = [...] is not yet supported.
        BONUSES[0] = Bonuses({ bonusRate: 125, expiration: startTime + 2 days });
        BONUSES[1] = Bonuses({ bonusRate: 120, expiration: startTime + 1 weeks });
        BONUSES[2] = Bonuses({ bonusRate: 115, expiration: startTime + 2 weeks });
        BONUSES[3] = Bonuses({ bonusRate: 110, expiration: startTime + 3 weeks });
        BONUSES[4] = Bonuses({ bonusRate: 105, expiration: startTime + 4 weeks });
    }

    uint256 constant LARGE_TRESHOLD = 100 ether;
    uint256 constant LARGE_TRESHOLD_BONUS = 110;

    function getBonusRate() view private returns (uint256) {
        // Check if the rate is different currently
        // BONUSES.some(x => x.expiration >= now)
        for (uint256 i = 0; i < BONUSES.length; i++) {
            if (BONUSES[i].expiration >= now) { 
                return rate
                    .div(100) // Divide first to avoid unnecessary overflow (rate must be X * 100)
                    .mul(BONUSES[i].bonusRate); // Calculate bonus rate
            }
        }
        // If all expired - regular rate
        return rate;
    }

    function getTotalBonus() private returns (uint256) {
        uint256 rate_ = getBonusRate(); // Get bonus rate
        // Apply large treshold bonus if applicable
        if (msg.value >= LARGE_TRESHOLD) {
            return rate_
                .div(100) // Divide first to avoid unnecessary overflow (rate must be X * 10'000)
                .mul(LARGE_TRESHOLD_BONUS);
        } else {
            return rate_;
        }
    }

    /**
     * NB: Any external calls inside of super.buyTokens would see the
     * wrong rate. The assumption here is that rate applies
     * only to buying tokens - and has no other exploitable side
     * effects.
     */
    function buyTokens(address beneficiary) public payable {
        uint256 rate_ = rate; // Store rate
        rate = getTotalBonus();
        super.buyTokens(beneficiary);
        rate = rate_; // Restore rate
    }
}
