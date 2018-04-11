pragma solidity ^0.4.18;

contract Withdrawable {

    mapping (address => uint) public pendingWithdrawals;

    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        
        require(amount > 0);
        require(this.balance >= amount);

        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}