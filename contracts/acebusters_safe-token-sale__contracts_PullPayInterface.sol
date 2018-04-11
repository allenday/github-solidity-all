pragma solidity ^0.4.11;

contract PullPayInterface {
  function asyncSend(address _dest) public payable;
}