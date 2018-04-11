pragma solidity ^0.4.7;
contract MainContract {
    address owner;
    address public delegate;
    uint public counter;

    function MainContract() {
        owner = msg.sender;
    }

    function setDelegate(address _delegate) {
        if (owner != msg.sender) {
            throw;
        }

        delegate = _delegate;
    }

    function bumpCounter(uint a) {
      if (address(0) == delegate) {
          throw;
      }
       bool ok = delegate.delegatecall(msg.data);
       if (!ok) {
           throw;
       }
    }
    
    function getCounter() constant returns (uint) {
        return counter;
    }
}