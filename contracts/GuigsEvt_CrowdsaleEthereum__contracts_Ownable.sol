pragma solidity ^0.4.14;

contract Ownable {
  address public owner;

  event ChangementOwnership(address indexed _by, address indexed _to);

  function Ownable() {
    owner = msg.sender;
  }

  /// @dev Reverts if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) external onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;

    ChangementOwnership(msg.sender, newOwner);
  }

}
