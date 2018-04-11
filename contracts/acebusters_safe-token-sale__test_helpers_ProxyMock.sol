pragma solidity ^0.4.11;

contract ProxyMock {

  event Deposit(address indexed sender, uint value);
  event Withdrawal(address indexed to, uint value, bytes data);
  
  // onwer of contract
  address public owner;
  
  function ProxyMock() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner) {
      _;
    }
  }
  
  function forward(address _destination, uint _value, bytes _data) onlyOwner {
    if (_destination == 0) {
      assembly {
        // deploy a contract
        _destination := create(0,add(_data,0x20), mload(_data))
      }
    } else {
      assert(_destination.call.value(_value)(_data)); // send eth or data
      if (_value > 0) {
        Withdrawal(_destination, _value, _data);
      }
    }
  }
   
  function() payable {
    Deposit(msg.sender, msg.value);
  }

  function tokenFallback(address _from, uint _value, bytes _data) {
  }
 
}