pragma solidity ^0.4.16;


contract IProxy {
  event Forwarded (address indexed destination, uint value, bytes data);
  event Received (address indexed sender, uint value);
  function forward(address destination, uint value, bytes data) public;
  function () public payable;
}
