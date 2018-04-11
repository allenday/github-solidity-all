pragma solidity ^0.4.0;

import "./environment.sol";

/**
 * An example base class for contract that is going to be bug-bountied.
 * You do not need to use this class for PYMWYCI to work.
 * 
 * NOTE however: it is important that the contract does not use the following 
 * directly:
 * block.blockhash, block.coinbase, block.difficulty, block.gaslimit, block.number
 * block.timestamp and now. 
 * Instead it should use the injected _env variable.
 * 
 * It is also advisable for a bountable contract to publicily expose as much of the
 * state variables as is feasible, because that will let its respective ContractTest 
 * verify its validity.
 */
contract ExampleTargetContract {
    EnvironmentContractInterface public env;
    address public owner;
    
    /**
     * @param _env the environment to use (usually testing or prod)
     * @param opt_owner if supplied, overrides the msg.sender. Use during bounties
     * 
     */
    function BountableContract(EnvironmentContractInterface _env, address opt_owner) {
        env = _env;
        // Note we dependency-inject the owner, to allow a Challenger to become
        // the owner of a contract.
        owner = (opt_owner != 0) ? opt_owner : msg.sender;
    }
}

