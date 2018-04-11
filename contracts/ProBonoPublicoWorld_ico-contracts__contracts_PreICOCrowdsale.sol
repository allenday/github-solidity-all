pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol";

import "./DualMintableToken.sol";
import "./ExternalTokenCrowdsale.sol";
import "./BonusCrowdsale.sol";

/**
 * Crowdsale with injected token, permissions have to be ensured by creator
 */
contract PreICOCrowdsale is CappedCrowdsale, RefundableCrowdsale, ExternalTokenCrowdsale, BonusCrowdsale {

    //As goal needs to be met for a successful crowdsale
    //the value needs to less or equal than a cap which is limit for accepted funds
    uint256 public constant GOAL = 1500 ether;
    uint256 public constant CAP = 30000 ether;
    
    function PreICOCrowdsale(
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
            start + 12 days, // 07:00am GMT 10 Nov 2017
            30000, // Rate
            _wallet
        )
        ExternalTokenCrowdsale(_token)
        BonusCrowdsale(
            40000, // Bonus Rate
            start + 1 days // Expiration of bonus rate
        )
    { }
}
