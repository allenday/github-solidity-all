pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "zeppelin-solidity/contracts/token/StandardToken.sol";
// import "./InitialDistribution.sol";
import "./MyFinalizableCrowdsale.sol";
import "./MultiCappedCrowdsale.sol";
import "./MyCrowdsaleToken.sol";

/**
 * @title MySale
 * @dev This is a sale with the following features:
 *  - erc20 based
 *  - Soft cap and hidden hard cap
 *  - When finished distributes percent to specific address based on whether the
 *    cap was reached.
 *  - Start and end block for the ico
 *  - Sends incoming eth to a specific address
 */
contract MySale is MyFinalizableCrowdsale, MultiCappedCrowdsale {

  // how many token units a buyer gets per wei
  uint256 public presaleRate;
  uint256 public postSoftRate;
  uint256 public postHardRate;
  uint256 public presaleEndTime;

  function MySale(uint256 _startTime, uint256 _endTime, uint256 _presaleEndTime, uint256 _rate, uint256 _rateDiff, uint256 _softCap, address _wallet, bytes32 _hardCapHash, address _tokenWallet, uint256 _endBuffer)
   MultiCappedCrowdsale(_softCap, _hardCapHash, _endBuffer)
   MyFinalizableCrowdsale(_tokenWallet)
   Crowdsale(_startTime, _endTime, _rate, _wallet)
  {
    presaleRate = _rate+_rateDiff;
    postSoftRate = _rate-_rateDiff;
    postHardRate = _rate-(2*_rateDiff);
    presaleEndTime = _presaleEndTime;
    // InitialDistribution.initialDistribution(token);
  }

  // Allows generating tokens for externally funded participants (other blockchains)
  function pregenTokens(address beneficiary, uint256 weiAmount, uint256 tokenAmount) external onlyOwner {
    require(beneficiary != 0x0);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokenAmount);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
  }

  // Overrides Crowdsale function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    uint256 currentRate = rate;
    if (block.timestamp < presaleEndTime) {
        currentRate = presaleRate;
    }
    else if (hardCap > 0 && weiRaised > hardCap) {
        currentRate = postHardRate;
    }
    else if (weiRaised > softCap) {
        currentRate = postSoftRate;
    }
    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(currentRate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // Overrides Crowdsale function
  function createTokenContract() internal returns (MintableToken) {
    return new MyCrowdsaleToken();
  }

  // Overrides MyFinalizableSale function
  function finalization() internal {
    if (weiRaised < softCap) {
      generateFinalTokens(1000);
    } else if (weiRaised < hardCap) {
      generateFinalTokens(666);
    } else {
      generateFinalTokens(428);
    }
    token.finishMinting();
    super.finalization();
  }

  /* Make sure no eth funds become stuck on contract */
  function withdraw(uint256 weiValue) onlyOwner {
    wallet.transfer(weiValue);
  }

}
