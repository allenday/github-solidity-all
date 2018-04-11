pragma solidity ^0.4.15;

import "StorageAdmin.sol";
import "dappsys/ds-note/note.sol";

contract StorageEther is StorageAdmin(){

  string public name;
  uint8 public decimals;
  string public symbol;

  function StorageEther(address tokenContract, address admin, address[] owners, uint required,
    string _name, string _symbol, uint8 _decimals) {
    _supply = 0;
    _admin = admin;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    for (uint i = 0; i < owners.length; i++) {
      _owners[i + 1] = owners[i];
      _ownerIndex[owners[i]] = i + 1;
    }
    _numOwners = owners.length;
    _required = required;
    _tokenContract = tokenContract;
  }

  function deposit(address to) note freezable external payable returns(bool) {
    _balances[to] += msg.value;
    _supply += msg.value;
    Deposit(msg.sender, to, msg.value);
    return true;
  }

  function() note freezable payable {
    TopUp(msg.sender, msg.value);
  }

  function internalTransfer() internal returns(bool) {
    for (uint i = 0; i < _numTransactions; i++) {
      assert(balanceOf(_sender) >= _transactionsValue[i]);
      _supply -= min(_transactionsValue[i], _balances[_sender]);
      _balances[_sender] -= min(_transactionsValue[i], _balances[_sender]);
      assert(_transactionsTo[i].call.value(_transactionsValue[i])());
      Transfer(_sender, _transactionsTo[i], _transactionsValue[i]);
    }
  }

  function balanceOf(address owner) constant returns(uint256 balance) {
    if (owner == _admin) {
      return max(0, (this.balance < _supply) ? 0 : this.balance - _supply) +
        _balances[owner];
    } else {
      return _balances[owner];
    }
  }

  function deleteContract(uint8[] sigV, bytes32[] sigR, bytes32[] sigS) note external {
    _numSignatures = sigV.length;
    for (uint i = 0; i < _numSignatures; i++) {
      _signatures[i].sigV = sigV[i];
      _signatures[i].sigR = sigR[i];
      _signatures[i].sigS = sigS[i];
    }
    assert(confirmAdminTx());
    suicide(_admin);
  }

  function sweep(address to, uint amount,
    uint8[] sigV, bytes32[] sigR, bytes32[] sigS) note freezable external {
    _numSignatures = sigV.length;
    for (uint i = 0; i < _numSignatures; i++) {
      _signatures[i].sigV = sigV[i];
      _signatures[i].sigR = sigR[i];
      _signatures[i].sigS = sigS[i];
    }

    assert(confirmAdminTx());
    assert(to.send(amount));
    Sweep(msg.sender, to, amount);
  }

  function topUp() note payable {
    TopUp(msg.sender, msg.value);
  }
}
