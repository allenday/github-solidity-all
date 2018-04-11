pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Claimable.sol';

contract Liquet is Claimable, StandardToken {
    string public constant name = "Liquet";
    string public constant symbol = "LQT";
    uint public constant decimals = 18;
    uint public constant totalSupply = 100e6 ether;
    string public constant version = "1.0";

    function Liquet() {
        balances[msg.sender] = totalSupply;
    }

    function() {
        revert();
    }
}
