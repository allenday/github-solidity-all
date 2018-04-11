pragma solidity ^0.4.15;

import "StorageAdmin.sol";
import "dappsys/erc20/erc20.sol";
import "dappsys/ds-note/note.sol";

contract StorageToken is StorageAdmin(){

  string public name;
  uint8 public decimals;
  string public symbol;

  function StorageToken(address tokenContract, address admin, address[] owners, uint required,
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

  function deposit(address to, uint256 value) note freezable external returns(bool) {
    ERC20 child = ERC20(_tokenContract);
    assert(child.transferFrom(msg.sender, this, value));
    _balances[to] += value;
    _supply += value;
    Deposit(msg.sender, to, value);
    return true;
  }

  function internalTransfer() internal returns(bool) {
    for (uint i = 0; i < _numTransactions; i++) {
      ERC20 child = ERC20(_tokenContract);
      assert(balanceOf(_sender) >= _transactionsValue[i]);
      _supply -= min(_transactionsValue[i], _balances[_sender]);
      _balances[_sender] -= min(_transactionsValue[i], _balances[_sender]);
      assert(child.transfer(_transactionsTo[i], _transactionsValue[i]));
      Transfer(_sender, _transactionsTo[i], _transactionsValue[i]);
    }
  }

  function balanceOf(address owner) constant returns(uint256 balance) {
    if (owner == _admin) {
      ERC20 child = ERC20(_tokenContract);
      return max(0, (child.balanceOf(this) < _supply) ? 0 : child.balanceOf(this) - _supply) +
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
    ERC20 child = ERC20(_tokenContract);
    child.transfer(_admin, child.balanceOf(this));
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
    ERC20 child = ERC20(_tokenContract);
    assert(child.transfer(to, amount));
    Sweep(msg.sender, to, amount);
  }
}
