pragma solidity ^0.4.15;

import "./SafeMath.sol";
import './KudosToken.sol';

/**
 * @title KudosTokenLockup
 * @author Ben Johnson
 *
 * @dev KudosTokenLockup is a token holder contract that will allow a beneficiary to extract the tokens after a year
 * @dev Based on TokenTimelock by OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity
 */
contract KudosTokenLockup {
   using SafeMath for uint256;

   KudosToken kudosToken;

   // beneficiary of tokens after they are released
   address public beneficiary;

   // timestamp when token release is enabled
   uint256 public releaseTime;

   function KudosTokenLockup(address _tokenContractAddress, address _beneficiary) {
      require(_tokenContractAddress != address(0));
      require(_beneficiary != address(0));
      releaseTime = now.add(1 years);
      kudosToken = KudosToken(_tokenContractAddress);
      beneficiary = _beneficiary;
   }

   /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
   function release() {
      require(now >= releaseTime);

      uint256 balance = kudosToken.balanceOf(this);
      require(balance > 0);

      assert(kudosToken.transfer(beneficiary, balance));
   }

   function fundsAreAvailable() constant returns (bool) {
      return now >= releaseTime;
   }
}
