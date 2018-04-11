pragma solidity ^0.4.16;

/**
 *  Ownable.sol v1.0.0
 * 
 *  Bilal Arif - https://twitter.com/furusiyya_
 *  Notary Platform
 */

contract Ownable {
  
    /*
      @title Ownable
      @dev The Ownable contract has an owner address, and provides basic authorization control
      functions, this simplifies the implementation of "user permissions".
    */

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable(address _owner){
    owner = _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}