pragma solidity ^0.4.17;

import "./Controlled.sol";

contract IControlled {
  function controller() public constant returns(address);
  function changeController(address _newController) public;
}

contract IStore is IControlled {
  function values(bytes20) public constant returns(uint);
  function set(bytes20, uint) public;
  function remove(bytes20) public;
}

contract IRegistry is IControlled {
  // function usernameToUser(bytes20) public constant returns(User);
  function ownerToUsername(address) public constant returns(bytes20);
  function userValueNames(uint) public constant returns(bytes20);
  function add(bytes20, address) public;
  function remove(bytes20) public;
  function addUserValueName(bytes20) public;
  function getOwner(bytes20) public returns(address);
  function getUserValue(bytes20, uint) public returns(uint);
  function setUserValue(bytes20, uint, uint) public;
}

contract IMiniMeToken is IControlled {
  function name() public constant returns(string);
  function decimals() public constant returns(uint8);
  function symbol() public constant returns(string);
  function version() public constant returns(string);
  function parentToken() public constant returns(IMiniMeToken);
  function parentSnapShotBlock() public constant returns(uint);
  function creationBlock() public constant returns(uint);
  function transfersEnabled() public constant returns(bool);
  function tokenFactory() public constant returns(ITokenFactory);
  function transfer(address, uint256) public returns (bool);
  function transferFrom(address, address, uint256) public returns (bool);
  function balanceOf(address) public returns (uint256);
  function approve(address, uint256) public returns (bool);
  function allowance(address, address) public returns (uint256);
  function approveAndCall(address, uint256, bytes) public returns (bool);
  function totalSupply() public returns (uint);
  function balanceOfAt(address, uint) public returns (uint);
  function totalSupplyAt(uint) public returns(uint);
  function createCloneToken(string, uint8, string, uint, bool) public returns(address);
  function generateTokens(address, uint) public returns (bool);
  function destroyTokens(address, uint) public returns (bool);
  function enableTransfers(bool) public;
}

contract ITokenFactory {
  function createCloneToken(address, uint, string, uint8, string, bool) public returns (IMiniMeToken);
}
