pragma solidity ^0.4.0;

// A contract that helps perform transactions and keeps reputation state.

// TODO multithreading issues:  http://solidity.readthedocs.io/en/develop/security-considerations.html

contract Transact {
    struct Reputation {
        int score;
        int pendingTransactions;
    }
    
    enum State {Created, Confirmed, Cancelled, Closed}
        
    event Created(uint id);
    event Confirmed(uint id);
    event Cancelled(uint id);
    event Closed(uint id);
    
    struct TransactionState {
        State state;  
        address from;
        address to;
        uint amount;
    }

    mapping (address => Reputation) public reputation;
    mapping (uint => TransactionState) public transactions;
    
    modifier onlyFrom(uint id) { require(msg.sender == transactions[id].from); _ ; }

    // reputation is successfull transactions, but penalized by pending transactions
    function getReputation(address add) public constant returns (int) {
        return reputation[add].score - reputation[add].pendingTransactions;
    }
    
    function createTransaction(uint id, address to) payable public {
      require(msg.value % 2 == 0);
      
      transactions[id] = TransactionState(State.Created,
        msg.sender, to,
        msg.value/2);
      Created(id);
    }
    
    function cancelTransaction(uint id) public onlyFrom(id) {
        require(transactions[id].state == State.Created);
          
        transactions[id].state = State.Cancelled;
        msg.sender.transfer(transactions[id].amount * 2);
        Cancelled(id);
    }
    
    function confirmTransaction(uint id, address from, uint amount) payable public {
        require(transactions[id].state == State.Created &&
           transactions[id].from == from &&
           transactions[id].to == msg.sender &&
           transactions[id].amount == amount &&
           msg.value == 2 * amount);
           
        transactions[id].state = State.Confirmed;
        reputation[transactions[id].to].pendingTransactions += 1;
        reputation[transactions[id].from].pendingTransactions += 1;
        
        Confirmed(id);
    }
    
    // successfull; everyone is happy
    function closeTransaction(uint id) public {
        require(transactions[id].to == msg.sender);
        transactions[id].state = State.Closed;
        
        transactions[id].from.transfer(3*transactions[id].amount);
        transactions[id].to.transfer(transactions[id].amount);
        
        reputation[transactions[id].to].score += 1;
        reputation[transactions[id].to].pendingTransactions -= 1;
        reputation[transactions[id].from].score += 1;
        reputation[transactions[id].from].pendingTransactions -= 1;
        
        Closed(id);
    }
    
    // didn't work out; we agree there was a potato, not a camera
    function refundTransaction(uint id) public {
        require(transactions[id].from == msg.sender);
        
        transactions[id].state = State.Closed;
        
        transactions[id].from.transfer(2*transactions[id].amount);
        transactions[id].to.transfer(2*transactions[id].amount);
        
        reputation[transactions[id].to].pendingTransactions -= 1;
        reputation[transactions[id].from].pendingTransactions -= 1;
        
        Closed(id);
    }
}
