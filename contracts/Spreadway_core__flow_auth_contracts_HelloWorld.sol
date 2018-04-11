pragma solidity ^0.4.4;

contract HelloWorld {
  //Begin: state variables
  address public creator;
  address public lastCaller;
  string public message;
  uint public totalGas;
  //End: state variables

  //Begin: constructor
  function HelloWorld() {
    /*
      We can use the special variable `tx` which gives us information
      about the current transaction.

      `tx.origin` returns the sender of the transaction.
      `tx.gasprice` returns how much we pay for the transaction
    */
    creator = tx.origin;
    totalGas = tx.gasprice;
    message = 'hello world';
  }
  //End: constructor

  //Begin: getters
  function getMessage() constant returns(string) {
    return message;
  }

  function getLastCaller() constant returns(address) {
    return lastCaller;
  }

  function getCreator() constant returns(address) {
    return creator;
  }

  function getTotalGas() constant returns(uint) {
    return totalGas;
  }
  //End: getters

  //Being: setters
  function setMessage(string newMessage) {
    message = newMessage;
    lastCaller = tx.origin;
    totalGas += tx.gasprice;
  }
  //End: setters
}