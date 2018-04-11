pragma solidity ^0.4.11;

contract Escrow {

  struct transaction {
    uint amount;
    uint collateral;
    address sender;
    address receiver;
    uint id;
    uint deadline;
    bool accepted;
    bool senderCanWithdraw;
    bool receiverCanWithdraw;
    bool complete;
  }

  transaction[] public transactions;
  uint numTransactions = 0;
  mapping (address => uint[]) sentTransactions;
  mapping (address => uint[]) recTransactions;

  address owner;

  modifier isReceiver(uint id){
    require(transactions[id].receiver == msg.sender);
    _;
  }

  modifier isSender(uint id){
    require(transactions[id].sender == msg.sender);
    _;
  }

  modifier isNotComplete(uint id){
    require(!transactions[id].complete);
    _;
  }

  function Escrow() {
    owner = msg.sender;
  }

  function makeTransaction(address receiver, uint deadline, uint collateral) payable {
    require(msg.value != 0);

    transactions.push(transaction({
      amount: msg.value,
      collateral: collateral,
      sender: msg.sender,
      receiver: receiver,
      id: numTransactions,
      deadline: deadline,
      accepted: false,
      senderCanWithdraw: true,
      receiverCanWithdraw: false,
      complete: false
      }));

    sentTransactions[msg.sender].push(numTransactions);
    recTransactions[receiver].push(numTransactions);
    numTransactions++;
  }

  function acceptTransaction(uint id) payable isReceiver(id) isNotComplete(id) {
    require(!transactions[id].accepted && msg.value == transactions[id].collateral);

    transactions[id].accepted = true;
    transactions[id].senderCanWithdraw = false;
    transactions[id].deadline = now + (transactions[id].deadline * 1 days);
  }

  function receiverWithdrawal(uint id) isReceiver(id) isNotComplete(id) {
    require(transactions[id].receiverCanWithdraw ||
    ((now > transactions[id].deadline) && (transactions[id].accepted)));

    uint collateral = transactions[id].collateral;
    uint fee = transactions[id].amount / 500;
    uint amount = transactions[id].amount - fee;
    transactions[id].complete = true;

    msg.sender.transfer(amount);
    owner.transfer(fee);
    transactions[id].receiver.transfer(collateral);
  }

  function senderWithdrawal(uint id) isSender(id) isNotComplete(id) {
    require(transactions[id].senderCanWithdraw);

    uint amount = transactions[id].amount;
    transactions[id].complete = true;

    if (transactions[id].accepted) {
      uint collateral = transactions[id].collateral;
      transactions[id].receiver.transfer(collateral);
    }

    msg.sender.transfer(amount);
    }

  function finalizeTransaction(uint id) isSender(id) isNotComplete(id) {
    require(!transactions[id].receiverCanWithdraw);

    transactions[id].receiverCanWithdraw = true;
    transactions[id].senderCanWithdraw = false;
  }

  function refundTransaction(uint id) isReceiver(id) isNotComplete(id) {
    require(transactions[id].accepted);

    transactions[id].receiverCanWithdraw = false;
    transactions[id].senderCanWithdraw = true;
  }

  function disputeTransaction(uint id, uint addedTime) isSender(id) isNotComplete(id) {
    require(now <= transactions[id].deadline && !transactions[id].receiverCanWithdraw);

    transactions[id].deadline += (addedTime * 1 days);
  }

  function getSentTransactionData(uint id) isSender(id) constant returns(uint amount,
                                                                     uint deadline,
                                                                     bool accepted,
                                                                     bool senderWithdrawl,
                                                                     uint collateral,
                                                                     bool complete) {
    return(
      transactions[id].amount,
      transactions[id].deadline,
      transactions[id].accepted,
      transactions[id].senderCanWithdraw,
      transactions[id].collateral,
      transactions[id].complete
      );
  }

  function getRecTransactionData(uint id) isReceiver(id) constant returns(uint amount,
                                                                  uint deadline,
                                                                  bool accepted,
                                                                  bool receiverCanWithdraw,
                                                                  uint collateral,
                                                                  bool complete) {

    bool withdraw = false;
    if (transactions[id].receiverCanWithdraw || now > transactions[id].deadline) {
      withdraw = true;
    }

    return(
      transactions[id].amount,
      transactions[id].deadline,
      transactions[id].accepted,
      withdraw,
      transactions[id].collateral,
      transactions[id].complete
      );
  }

  function getSentTransactions() constant returns(uint[] ids,
                                                  address[] addresses) {
    uint length = 0;
    for (uint p = 0; p < sentTransactions[msg.sender].length; p++){
      var z = transactions[sentTransactions[msg.sender][p]];
      if (!z.complete) {
        length++;
      }
    }

    uint[] memory returnIds = new uint[](length);
    address[] memory returnAddresses = new address[](length);
    uint num = 0;

    for (uint i = 0; i < sentTransactions[msg.sender].length; i++) {
      var x = transactions[sentTransactions[msg.sender][i]];
      if (!x.complete) {
        returnIds[num] = x.id;
        returnAddresses[num] = x.receiver;
        num++;
      }
    }

    return(returnIds, returnAddresses);
  }

  function getRecTransactions() constant returns(uint[] ids,
                                                  address[] addresses) {
  uint length = 0;
  for (uint p = 0; p < sentTransactions[msg.sender].length; p++) {
    var z = transactions[sentTransactions[msg.sender][p]];
      if (!z.complete) {
        length++;
      }
    }

    uint[] memory returnIds = new uint[](length);
    address[] memory returnAddresses = new address[](length);
    uint num = 0;

    for (uint i = 0; i < recTransactions[msg.sender].length; i++) {
      var x = transactions[recTransactions[msg.sender][i]];
      if (!x.complete) {
      returnIds[num] = x.id;
      returnAddresses[num] = x.receiver;
      num++;
      }
    }

    return(returnIds, returnAddresses);
  }

  function () {
    revert();
  }
}
