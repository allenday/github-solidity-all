pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/crowdsale/Crowdsale.sol';

/**
 * @title MultiCappedCrowdsale
 * @dev Extension of Crowsdale with a soft cap and a hard cap.
 * after finishing. By default, it will end token minting.
 */
contract MultiCappedCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  uint256 public softCap;
  uint256 public hardCap = 0;
  bytes32 public hardCapHash;
  uint256 public hardCapTime = 0;
  uint256 public endBuffer;
  event NotFinalized(bytes32 _a, bytes32 _b);

  function MultiCappedCrowdsale(uint256 _softCap, bytes32 _hardCapHash, uint256 _endBuffer) {
    require(_softCap > 0);
    softCap = _softCap;
    hardCapHash = _hardCapHash;
    endBuffer = _endBuffer;
  }

  //
  //  Soft cap logic
  //
  
  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    if (hardCap > 0) {
      checkHardCap(weiRaised.add(msg.value));
    }
    return super.validPurchase();
  }

  //
  //  Hard cap logic
  //

  function hashHardCap(uint256 _hardCap, uint256 _key) internal constant returns (bytes32) {
    return keccak256(_hardCap, _key);
  }

  function setHardCap(uint256 _hardCap, uint256 _key) external onlyOwner {
    require(hardCap==0);
    if (hardCapHash != hashHardCap(_hardCap, _key)) {
      NotFinalized(hashHardCap(_hardCap, _key), hardCapHash);
      return;
    }
    hardCap = _hardCap;
    checkHardCap(weiRaised);
  }



  function checkHardCap(uint256 totalRaised) internal {
    if (hardCapTime == 0 && totalRaised > hardCap) {
      hardCapTime = block.timestamp;
      endTime = block.timestamp+endBuffer;
    }
  }

}
