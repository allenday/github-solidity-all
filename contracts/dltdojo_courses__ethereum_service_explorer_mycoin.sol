pragma solidity ^0.4.14;

// JavaScript VM
// mint account0,1200
// balances account0
// send account1,20
// balances account1
// events

// Web3 Provider http://VMIP:8545
// mint account0,1200
// balances account0
// send account1,20
// balances account1
// events

// MyWallet 
// transfer account1

contract Coin {
    // The keyword "public" makes those variables
    // readable from outside.
    address public minter;
    mapping (address => uint) public balances;

    // Events allow light clients to react on
    // changes efficiently.
    event Sent(address from, address to, uint amount);

    // This is the constructor whose code is
    // run only when the contract is created.
    function Coin() {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount);
    }
}

contract MyWallet {
    function transfer(address to) payable {
        to.transfer(msg.value);
    }
}