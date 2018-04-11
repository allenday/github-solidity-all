pragma solidity 0.4.16;

import "utils/IOwned.sol";

// a special Owned contract with trander method
contract Owned is IOwned {
  address public owner;
  modifier onlyOwner() { require(isOwner(msg.sender)); _; }

  function Owned() public { owner = msg.sender; }

  function isOwner(address addr) public constant returns(bool) { return addr == owner; }

  function transfer(address _owner) public onlyOwner {
    owner = _owner;
  }
}
