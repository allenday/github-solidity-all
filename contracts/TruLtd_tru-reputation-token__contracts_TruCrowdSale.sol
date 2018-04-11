/// @title Tru Reputation Token Crowdsale
/// @notice Tru Reputation Protocol Crowdsale contract based on Open Zeppelin and 
/// TokenMarket. This CrowdSale is modified to include the following features:
/// - Crowdsale time period
/// - Discount at 10%
/// - Completion function can be called by owner to close minting, and enable transferring Tokens
/// @author Ian Bray
pragma solidity 0.4.18;

import "./TruReputationToken.sol";
import "./TruSale.sol";
import "./supporting/SafeMath.sol";


contract TruCrowdSale is TruSale {
    
    using SafeMath for uint256;
  
    /// @notice Cap on Pre-Sale and CrowdSale in Wei (Ξ55,000) (55000 x POWER(10,18))
    /// is updated when constructed to remove sold amount in the Pre-Sale
    uint256 public constant TOTAL_CAP = 55000 * 10**18;

    uint256 public existingSupply = 0;

    /// @notice TruCrowdSale Contract constructor
    /// @param _startTime The Start Time of the Sale as a uint256
    /// @param _endTime The End Time of the Sale as a uint256
    /// @param _saleWallet The MultiSig wallet address used to hold funds for the CrowdSale
    /// @param _token The Tru Reputation Token Contract Address used to mint tokens purchases
    function TruCrowdSale(
        uint256 _startTime, 
        uint256 _endTime, 
        address _token, 
        address _saleWallet,
        uint256 _currentSupply, 
        uint256 _currentRaise) public TruSale(_startTime, _endTime, _token, _saleWallet)
    {
        isPreSale = false;
        isCrowdSale = true;
        uint256 remainingCap = TOTAL_CAP.sub(_currentRaise);
        cap = remainingCap;
        existingSupply = _currentSupply;
    }

    /// @notice Internal Function to finalise the CrowdSale in accordance with the Pre-Sale terms
    function finalise() public onlyOwner {
        require(!isCompleted);
        require(hasEnded());

        completion();
        Completed(msg.sender);

        isCompleted = true;
    }

    /// @notice Function to complete CrowdSale. Doubles the sold amount and transfers it to the  Multisig wallet
    function completion() internal {
     
        // Double sold pool to allocate to Tru Resource Pools
        uint256 poolTokens = truToken.totalSupply();
        poolTokens = poolTokens.sub(existingSupply);

        // Issue poolTokens to multisig wallet
        truToken.mint(multiSigWallet, poolTokens);
        truToken.finishMinting(false, true);
        truToken.transferOwnership(msg.sender);
        truToken.releaseTokenTransfer();
    }
}