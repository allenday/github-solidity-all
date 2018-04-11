pragma solidity ^0.4.2;

/*
 * A contract to be used for testing the invocation of another contract's functions from a known address, using Solidity.
 *
 * This is necessary when testing, a contract, through another Solidity contract because there isn't the equivalent of calling a function with
 * the { from: <address> } argument (to change the caller address of the function) that we use when testing a contract using JS / Web3.js.
 *
 * Based on the concepts described in the article "testing for throws in solidity tests" (http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests)
 */
contract ContractCallerProxy {

    address public target;
    bytes data;

    function ContractCallerProxy(address _target) {
        target = _target;
    }

    //prime the data using the fallback function.
    function() {
        data = msg.data;
    }

    function execute() returns (bool) {
        return target.call(data);
    }
}