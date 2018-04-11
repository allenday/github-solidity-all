pragma solidity ^0.4.14;

contract Coin {
    
    address public minter;
    
    mapping (address => uint) public balances;

    // Events allow light clients to react on changes efficiently.
    event Sent(address from, address to, uint amount);

    // This is the constructor whose code is run only when the contract is created.
    function Coin() {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) {
        require(balances[msg.sender] > amount);
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount);
    }
}

// TODO
// JavaScript VM
// mint account0,1200
// balances account0
// send account1,20
// balances account1