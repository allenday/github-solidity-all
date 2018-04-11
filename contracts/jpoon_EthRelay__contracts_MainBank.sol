pragma solidity ^0.4.4;

contract MainBank {

  mapping(uint => uint) RuralBankBalances;
  address admin;

  event transferExecuted(uint sourceBank, uint sourceAccountNumber, uint targetBank, uint targetAccountNumber, uint amount, uint transferId);
  event revertTransferExecuted(uint sourceBank, uint sourceAccountNumber, uint targetBank, uint targetAccountNumber, uint amount, uint trasferId);
  event transferCompleted(uint transferId);
  event transferFailed(uint transferId);  

  function MainBank() {
    admin = msg.sender;
  }

  function getBalance(uint bank) constant returns(uint) {
    return RuralBankBalances[bank];
  }

  function transfer(uint sourceBank, uint sourceAccountNumber, uint targetBank, uint targetAccountNumber, uint amount, uint transferId) {
    internalTransfer(sourceBank, targetBank, amount);
    transferExecuted(sourceBank, sourceAccountNumber, targetBank, targetAccountNumber, amount, transferId);
  }

  function revertTransfer(uint sourceBank, uint sourceAccountNumber, uint targetBank, uint targetAccountNumber, uint amount, uint transferId) {
    internalTransfer(targetBank, sourceBank, amount);
    revertTransferExecuted(sourceBank, sourceAccountNumber, targetBank, targetAccountNumber, amount, transferId);
  }

  function internalTransfer(uint sourceBank, uint targetBank, uint amount) private {
    debit(sourceBank, amount);
    credit(targetBank, amount);
  }

  function completeTransfer(uint transferId) {
    transferCompleted(transferId);
  }

  function rejectTransfer(uint transferId) {
    transferFailed(transferId);
  }

  function credit(uint bank, uint amount) {
    require(amount > 0);
    RuralBankBalances[bank] += amount;
    assert(RuralBankBalances[bank] >= amount);
  }

  function debit(uint bank, uint amount) {
    require(RuralBankBalances[bank] > amount);
    RuralBankBalances[bank] -= amount;
  }

}