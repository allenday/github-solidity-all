pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

import "./DualMintableToken.sol";
import "./ExternalTokenCrowdsale.sol";
import "./MultiBonusCrowdsale.sol";

/**
 * Crowdsale with injected token, permissions have to be ensured by creator
 */
contract ICOCrowdsale is CappedCrowdsale, RefundableCrowdsale, ExternalTokenCrowdsale, MultiBonusCrowdsale {
    using SafeMath for uint256;

    //As goal needs to be met for a successful crowdsale
    //the value needs to less or equal than a cap which is limit for accepted funds
    uint256 public constant GOAL = 6000 ether;
    uint256 public constant CAP = 350000 ether;

    function ICOCrowdsale(
        address _wallet,
        DualMintableToken _token,
        uint256 start
    ) 
        public
        CappedCrowdsale(CAP) // Cap
        FinalizableCrowdsale()
        RefundableCrowdsale(GOAL) // Goal
        Crowdsale(
            start,
            start + 25 days, // 07:00am GMT 15 Dec 2017
            20000,
            _wallet
        )
        ExternalTokenCrowdsale(_token)
        MultiBonusCrowdsale()
    { }

    function finalization() internal {
        uint256 proportion = token.totalSupply().div(80 / 20); // Calculate proportion based on ratio
        token.mint(wallet, proportion);
        token.finishMinting(); // Don't check the result since it will throw if not true
        super.finalization();
    }
}
