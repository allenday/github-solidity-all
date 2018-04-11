pragma solidity ^0.4.15;

import "../token/Standard23Token.sol";

/**
 * @title ExampleReceiver 
 *
 * created by IAM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: ExampleToken.sol
 * location: ERC23/contracts/example/
 *
*/
contract ExampleToken is Standard23Token {
  
    function ExampleToken(uint initialBalance) {
        balances[msg.sender] = initialBalance;
        totalSupply = initialBalance;
        // Ideally call token fallback here too
    }
}