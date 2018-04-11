pragma solidity ^0.4.18;


/// @title SafeOwnable
/// @dev The SafeOwnable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".
contract SafeOwnable {

  // EVENTS

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  // PUBLIC FUNCTIONS

  /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
  function SafeOwnable() public {
    owner = msg.sender;
  }

  /// @dev Allows the current owner to transfer control of the contract to a newOwner.
  /// @param newOwner The address to transfer ownership to.
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0) && newOwner != owner);
    ownerCandidate = newOwner;
  }

  /// @dev Allows the current owner candidate approve ownership and set actual owner of a contract.
  function approveOwnership() onlyOwnerCandidate public {
    owner = ownerCandidate;
    ownerCandidate = address(0);
    OwnershipTransferred(owner, ownerCandidate);
  }

  // MODIFIERS

  /// @dev Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /// @dev Throws if called by any account other than the owner candidate.
  modifier onlyOwnerCandidate() {
    require(msg.sender == ownerCandidate);
    _;
  }

  // FIELDS

  address public owner;
  address public ownerCandidate;
}
