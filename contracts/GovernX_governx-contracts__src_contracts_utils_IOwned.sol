pragma solidity 0.4.16;

// a special Owned contract interface with trander method
contract IOwned {
  function isOwner(address addr) public constant returns(bool);
  function transfer(address _owner) public;
}
