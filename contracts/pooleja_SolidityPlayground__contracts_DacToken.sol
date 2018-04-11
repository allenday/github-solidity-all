pragma solidity ^0.4.4;
import "./StandardToken.sol";

contract DacToken is StandardToken {
    string public name = "DA.Capital"; 
    string public symbol = "DAC";
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 21000000 * 10**18;

    function DacToken() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}|