pragma solidity ^0.4.11;

import "./Zeppelin/Ownable.sol";
import "./Finalizable.sol";

contract Shared is Ownable, Finalizable {
  uint internal constant DECIMALS = 8;
  
  address internal constant REWARDS_WALLET = 0x30b002d3AfCb7F9382394f7c803faFBb500872D8;
  address internal constant CROWDSALE_WALLET = 0x028e1Ce69E379b1678278640c7387ecc40DAa895;
  address internal constant LIFE_CHANGE_WALLET = 0xEe4284f98D0568c7f65688f18A2F74354E17B31a;
  address internal constant LIFE_CHANGE_VESTING_WALLET = 0x2D354bD67707223C9aC0232cd0E54f22b03483Cf;
}