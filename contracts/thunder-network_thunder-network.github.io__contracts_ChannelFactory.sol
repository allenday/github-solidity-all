pragma solidity ^0.4.4;

import "./Channel.sol";

contract ChannelFactory {
  function ChannelFactory () {}

  event ChannelCreated(address indexed from, address indexed to, address indexed contractAddress, uint256 value);

  function createChannel (address partner) payable {
    Channel contractAddress=  new Channel(msg.sender, partner);
    contractAddress.initialDeposit.value(msg.value)(msg.sender);
    ChannelCreated(msg.sender, partner, contractAddress, msg.value);
  }
}
