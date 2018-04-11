pragma solidity ^0.4.14;

import "./GuigsToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

// Import directly from zeppelin-solidity crowdsale contracts but unabled to import directly from zeppelin-solidity npm package
import './CappedCrowdsale.sol';
import './FinalizableCrowdsale.sol';

/**
 * @title GuigsTokenSale
 * @dev Capped crowdsale for GuigsTokenSale, it is capped crowdsale and refundable
 * if min cap is not reach
 * Only whitelisted addresses added by the owner of the contract can
 * buy tokens
 * For purposes where whitelist is not required it only requires
 * to remove fromWhitelistedAddr() modifier
 */
contract GuigsTokenSale is CappedCrowdsale, FinalizableCrowdsale {

  address public foundersAddress;

  /** Corresponds to the amount of tokens that have been allocated during presale
  * All of the tokens are sent to the presale address at the end of the crowdsale
  * Distribution will is made after crowdsale based on presale participation
  */
  address public presaleDistributionAddress;
  uint256 public tokenPresaleDistribution;


  /**
   * @param startBlock block at which we can start send Ether to the crowdsale
   * @param endBlock block at which the crowdsale ends
   * @param cap minimum cap requirement in wei
   * @param wallet address at which the ethers raised will be sent
   * @param _foundersAddress address at which the tokens distributed to the team will be sent
   * @param _presaleDistributionAddress address at which the presale distribution tokens will be sent
   * @param _tokenPresaleDistribution number of tokens allocated to the presale addresses
   */
  function GuigsTokenSale(
    uint256 startBlock, uint256 endBlock, uint256 rate,
    uint256 cap, address wallet,
    address _foundersAddress, address _presaleDistributionAddress, uint256 _tokenPresaleDistribution
  ) CappedCrowdsale(cap)
    FinalizableCrowdsale()
    Crowdsale(startBlock, endBlock, rate, wallet)
  {

    require(_foundersAddress != address(0));
    require(_presaleDistributionAddress != address(0));

    foundersAddress = _foundersAddress;
    presaleDistributionAddress = _presaleDistributionAddress;
    tokenPresaleDistribution = _tokenPresaleDistribution;
  }

  // override buyTokens function to allow only whitelisted addresses buy 
  function buyTokens(address beneficiary) payable {
    super.buyTokens(beneficiary);
  }

  // finalization function called by the finalize function that will distribute
  // the remaining tokens
  function finalization() internal {
    uint256 tokensSold = token.totalSupply();

    // We then mint the token for the presaleDistribution that will then be distributed to each participant of the presale
    token.mint(presaleDistributionAddress, tokenPresaleDistribution);

    // Before closing the token sale we add 10% of the overall token supply to the founders address
    uint256 foundersTokens = tokensSold.mul(1000).div(10000);
    token.mint(foundersAddress, foundersTokens);

    // Finish minting.
    token.endMinting();

    super.finalization();
  }

}
