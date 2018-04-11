pragma solidity ^0.4.16;

contract Hello {

    mapping(address => uint256) public balances;

    function () payable{
        balances[msg.sender] += msg.value;
    }
        
}
