pragma solidity ^0.4.14;
// 
// gnosis/gnosis-contracts: Collection of smart contracts for the Gnosis prediction market platform. 
// https://github.com/gnosis/gnosis-contracts/

contract PredictionMarketEventFooTrue {
    
    uint public tokenCount = 1000;
    
    function buy(uint _amount) returns (uint){
        tokenCount += _amount;
    }
    
    function sell(uint _amount) returns (uint){
        require(tokenCount>_amount);
        tokenCount -= _amount;
    }
    
    function outcome() returns (bool){
        return tokenCount > 1000;
    }
}

contract Foo {
    
    PredictionMarketEventFooTrue oracle;
    
    function setOracle(address _addrOracle){
        oracle =PredictionMarketEventFooTrue(_addrOracle);
    }
    
    function askOracle() returns (bool){
        return oracle.outcome();
    }
}