pragma solidity ^0.4.13;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Benable
 * @dev Extension for the Ownable contract, with `benship` (ability to change beneficiary).
 */
contract Benable is Ownable {
  address public ben; // beneficiary

  event BenshipTransferred(address indexed prevAddr, address indexed newAddr);

  /**
   * @dev The Benable constructor sets the original `ben` of the contract to the sender
   * account.
   */
  function Benable() {
    ben = msg.sender;
  }


  /**
   * @dev Modifier throws if called by any account other than the ben.
   */
  modifier onlyBen() {
    require(msg.sender == ben);
    _;
  }


  /**
   * @dev Allows the current ben to set the ben address.
   * @param newAddr The address to transfer benship to.
   */
  function transferBenship(address newAddr) onlyBen public {
    require(newAddr != address(0));
    BenshipTransferred(ben, newAddr);
    ben = newAddr;
  }

}
