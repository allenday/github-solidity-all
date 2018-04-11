pragma solidity ^0.4.13;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Devable
 * @dev Extension for the Ownable contract, with `devship` (ability to change developer).
 */
contract Devable is Ownable {
  address public dev; // developer

  event DevshipTransferred(address indexed prevAddr, address indexed newAddr);

  /**
   * @dev The Devable constructor sets the original `dev` of the contract to the sender
   * account.
   */
  function Devable() {
    dev = msg.sender;
  }


  /**
   * @dev Modifier throws if called by any account other than the dev.
   */
  modifier onlyDev() {
    require(msg.sender == dev);
    _;
  }


  /**
   * @dev Allows the current dev to set the dev address.
   * @param newAddr The address to transfer devship to.
   */
  function transferDevship(address newAddr) onlyDev public {
    require(newAddr != address(0));
    DevshipTransferred(dev, newAddr);
    dev = newAddr;
  }

}
