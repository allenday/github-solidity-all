pragma solidity 0.4.15;

import "./Killable.sol";

contract Splitter is Killable{
    mapping(address => uint) public recipientBalances;

    event LogSplit(address indexed sender, address indexed recipient1, address indexed recipient2, uint splitAmount); 
    event LogWithdraw(address indexed recipient, uint withdrawAmount);

    function split(address recipient1, address recipient2) 
        public
        isNotPaused
        isNotKilled
        payable
        returns(bool success)
    {
        uint quotient;
        uint remainder;

        require(recipient1 != address(0));
        require(recipient2 != address(0));
        require(recipient1 != recipient2);
        require(msg.value > 0);

        quotient  = msg.value / 2;
        remainder = msg.value - 2 * quotient;

        require(quotient > 0);

        recipientBalances[recipient1] += quotient;
        recipientBalances[recipient2] += quotient;

        if (remainder > 0) {
            recipientBalances[msg.sender] += remainder;
        }

        LogSplit(msg.sender, recipient1, recipient2, msg.value);

        return true;
    }

    function withdraw()
        public
        isNotPaused
        isNotKilled
        returns(bool success)
    {
        require(recipientBalances[msg.sender] > 0);

        uint withdrawAmount = recipientBalances[msg.sender];

        recipientBalances[msg.sender] = 0;

        msg.sender.transfer(withdrawAmount);
        LogWithdraw(msg.sender, withdrawAmount);

        return true;
    }
}