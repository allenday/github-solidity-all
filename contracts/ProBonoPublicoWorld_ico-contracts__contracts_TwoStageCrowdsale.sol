pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "./DualMintableToken.sol";
import "./PBToken.sol";
import "./ICOCrowdsale.sol";
import "./PreICOCrowdsale.sol";


/**
 * @title TwoStageCrowdsale
 * @dev Dual crowdsale deployment contract
 * Finalization functions are separated due to potentially different requirements
 */
contract TwoStageCrowdsale is Ownable {
    PreICOCrowdsale public preICOCrowdsale;
    ICOCrowdsale public _ICOCrowdsale;
    DualMintableToken public token;

    function TwoStageCrowdsale(uint256 preICOStart, uint256 start, address wallet_) public {
        // Potential values
        // uint256 preICOStart = 1509346800; // 07:00am GMT 30 Oct 2017 
        // uint256 start = 1511161200; // 07:00am GMT 20 Nov 2017

        // Create dual mintable token and take both ownership slots
        token = createTokenContract();

        // Create crowdsales
        preICOCrowdsale = new PreICOCrowdsale(
            wallet_,
            token,
            preICOStart
        );
        
        _ICOCrowdsale = new ICOCrowdsale(
            wallet_,
            token,
            start
        );

        // Transfer ownerships afterwards due to circular dependencies
        token.transferOwnership(preICOCrowdsale);
        token.transferOwnership(_ICOCrowdsale); // Transfer second of double ownership
    }

    // Finalize crowdsale A
    function finalizePreICO() onlyOwner public {
        preICOCrowdsale.finalize();
    }

    // Finalize crowdsale B
    function finalizeICO() onlyOwner public {
        _ICOCrowdsale.finalize();
    }

    // Following crowdsale pattern, NB: has to be doubly owned
    function createTokenContract() internal returns (DualMintableToken) {
        return new PBToken(this, this);
    }
}
