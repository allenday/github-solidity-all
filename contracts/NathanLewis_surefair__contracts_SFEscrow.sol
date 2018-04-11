pragma solidity ^0.4.0;

contract SFEscrow{
    
    address public owner;
    uint256 totalBalance;
    
    // Helper to restrict invocation to owner
    modifier only_owner() {
        if (msg.sender == owner) {
            _;
        }
    }
    
    // Constructor
    function SFEscrow() {
        owner = msg.sender;
        totalBalance = 0;
    }
    
    
    function deposit(uint256 amount) external only_owner{
        if(amount < 0){
            throw;
        }
        totalBalance += amount;
    }
    
    function payout(address payee, uint256 amount) external only_owner{
        if(amount <= 0){
            throw;
        }
        payee.transfer(amount);
    }
    
}