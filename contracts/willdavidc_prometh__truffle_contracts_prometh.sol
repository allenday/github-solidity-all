pragma solidity ^0.4.15;

import "./agent.sol";

contract prometh {
    
    agent public promethAgent;
    
    function prometh (address _contractAddress) payable public
    {
        promethAgent = agent(_contractAddress);
    }
    
    function lookup() constant public returns (uint128, uint128)
    {
        var (gasNeeded, payout) =  promethAgent.promethCost();
        gasNeeded += 60000;
        return (gasNeeded, payout);
    }
    
    function execute(uint128 expectedGas, uint128 expectedPayout) public
    {
        var (gasNeeded, payout) = promethAgent.promethCost.gas(2000)();
        if (expectedPayout > this.balance || payout < expectedPayout || expectedGas < gasNeeded + 60000 || msg.gas < gasNeeded + 25000) {
            return; //use revert() when Byzantine hits
        }
        msg.sender.transfer(payout);
        promethAgent.promethExecute.gas(gasNeeded + 1000)();
        return;
    }

    function loadFunds() payable {
        return;
    }

    function () payable {
        return;
    }

}