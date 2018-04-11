pragma solidity ^0.4.2;

contract ERC20 {

    function totalSupply() constant returns (uint totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

}

contract ERC20Voting {

    mapping (bytes32 => uint) public tokensReceived;
    ERC20 public token;

    function ERC20Voting(address tokenAddress) {
        token = ERC20(tokenAddress);
    }

    function totalVotesFor(bytes32 candidate) returns (uint) {
        return tokensReceived[candidate];
    }

    function vote(bytes32 candidate, uint numTokens) {
        if(token.transferFrom(msg.sender, this, numTokens)) {
            tokensReceived[candidate] += numTokens;
        }
    }

}
