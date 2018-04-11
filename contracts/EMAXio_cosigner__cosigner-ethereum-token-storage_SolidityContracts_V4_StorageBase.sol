pragma solidity ^0.4.15;

import "dappsys/ds-token/base.sol";

contract StorageBase is DSTokenBase(0) {
  address _tokenContract;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Deposit(address indexed _from, address indexed _to, uint256 _value);
  event Reconcile(address indexed _affected, int256 _value);
  event Sweep(address indexed _requestor, address indexed _to, uint256 _value);
  event TopUp(address indexed _sender, uint256 _value);
  event ContractFrozen(bool _frozen);

  function StorageBase(address child) {
    _tokenContract = child;
  }

  // Override Token functions we don't want enabled in our exchange contract
  function transfer(address dst, uint wad) returns (bool) {
    return false;
  }

  function transferFrom(address src, address dst, uint wad) returns (bool) {
    return false;
  }

  function approve(address guy, uint256 wad) returns (bool) {
    return false;
  }
}
