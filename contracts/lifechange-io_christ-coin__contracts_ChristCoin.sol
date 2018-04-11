pragma solidity ^0.4.11;

import "./Zeppelin/SafeMath.sol";
import "./Controller.sol";
import "./Shared.sol";

/** @title Christ Coin Token */
contract ChristCoin is Shared {
  using SafeMath for uint;

  string public name = "Christ Coin";
  string public symbol = "CCLC";
  uint8 public decimals = 8;

  Controller public controller;

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);

  function setController(address _address) onlyOwner notFinalized {
    controller = Controller(_address);
  }

  modifier onlyController() {
    require(msg.sender == address(controller));
    _;
  }

  function balanceOf(address _owner) constant returns (uint) {
    return controller.balanceOf(_owner);
  }

  function totalSupply() constant returns (uint) {
    return controller.totalSupply();
  }

  function transfer(address _to, uint _value) returns (bool success) {
    success = controller.transfer(msg.sender, _to, _value);
    if (success) {
      Transfer(msg.sender, _to, _value);
    }
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    success = controller.transferFrom(msg.sender, _from, _to, _value);
    if (success) {
      Transfer(_from, _to, _value);
    }
  }

  function approve(address _spender, uint _value) returns (bool success) {
    success = controller.approve(msg.sender, _spender, _value);
    if (success) {
      Approval(msg.sender, _spender, _value);
    }
  }

  function allowance(address _owner, address _spender) constant returns (uint) {
    return controller.allowance(_owner, _spender);
  }

  function burn(uint _amount) onlyOwner returns (bool success) {
    success = controller.burn(msg.sender, _amount);
    if (success) {
      Transfer(msg.sender, 0x0, _amount);
    }
  }

  // Allows controller to call Transfer event when minting or transferring crowdsale tokens
  function controllerTransfer(address _from, address _to, uint _value) onlyController {
    Transfer(_from, _to, _value);
  }

  // Allows controller to call Approval in the future if needed
  function controllerApproval(address _from, address _spender, uint _value) onlyController {
    Approval(_from, _spender, _value);
  }
}