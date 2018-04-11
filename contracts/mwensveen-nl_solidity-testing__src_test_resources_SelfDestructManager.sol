pragma solidity ^0.4.7;
contract SelfDestructManager {
    address owner;
    SelfDestruct sdContract;
    uint public value;

    function SelfDestructManager() {
        owner = msg.sender;
        sdContract = new SelfDestruct();
    }

    function give() payable {
     value = msg.value;
     sdContract.send(msg.value);
    }
  
    function endContract() {
        if (owner != msg.sender) {
            throw;
        }
        SelfDestruct sd = SelfDestruct(sdContract);
        sd.endContract();
    }
}
contract SelfDestruct {
    address owner;

    function SelfDestruct() {
        owner = msg.sender;
    }

    function() payable {
        
    }
    function endContract() {
        if (owner != msg.sender) {
            throw;
        }
        selfdestruct(owner);
    }
}