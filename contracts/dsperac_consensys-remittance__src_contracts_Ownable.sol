pragma solidity ^0.4.5;

contract Ownable {
  address public owner;

  modifier onlyOwner() {
    if (msg.sender == owner)
    _;
  }

  function Ownable() {
    owner = msg.sender;
  }
}
