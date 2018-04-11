pragma solidity ^0.4.18;


/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".
contract Ownable {

  // EVENTS

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  // PUBLIC FUNCTIONS

  /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
  function Ownable() public {
    owner = msg.sender;
  }

  /// @dev Allows the current owner to transfer control of the contract to a newOwner.
  /// @param newOwner The address to transfer ownership to.
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  // MODIFIERS

  /// @dev Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // FIELDS

  address public owner;
}
