pragma solidity ^0.4.11;

import "./Zeppelin/SafeMath.sol";
import "./Shared.sol";

/** @title Ledger for the Christ Coin Token */
contract Ledger is Shared {
  using SafeMath for uint;

  address public controller;
  mapping(address => uint) public balanceOf;
  mapping (address => mapping (address => uint)) public allowed;
  uint public totalSupply;

  function setController(address _address) onlyOwner notFinalized {
    controller = _address;
  }

  modifier onlyController() {
    require(msg.sender == controller);
    _;
  }

  function transfer(address _from, address _to, uint _value) onlyController returns (bool success) {
    balanceOf[_from] = balanceOf[_from].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    return true;
  }

  function transferFrom(address _spender, address _from, address _to, uint _value) onlyController returns (bool success) {
    var _allowance = allowed[_from][_spender];
    balanceOf[_to] = balanceOf[_to].add(_value);
    balanceOf[_from] = balanceOf[_from].sub(_value);
    allowed[_from][_spender] = _allowance.sub(_value);
    return true;
  }

  function approve(address _owner, address _spender, uint _value) onlyController returns (bool success) {
    require((_value == 0) || (allowed[_owner][_spender] == 0));
    allowed[_owner][_spender] = _value;
    return true;
  }

  function allowance(address _owner, address _spender) onlyController constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  function burn(address _from, uint _amount) onlyController returns (bool success) {
    balanceOf[_from] = balanceOf[_from].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    return true;
  }

  function mint(address _to, uint _amount) onlyController returns (bool success) {
    balanceOf[_to] += _amount;
    totalSupply += _amount;
    return true;
  }
}