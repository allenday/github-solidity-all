import "./StandardToken.sol";

pragma solidity ^0.4.15;

contract OracleChainToken is StandardToken {

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name="OracleChainToken";                   //fancy name: eg Simon Bucks
    uint8 public decimals=8;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol="OCT";                 //An identifier: eg SBX
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function OracleChainToken(
    uint256 _initialAmount,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol
    ) {
        balances[msg.sender] = 1000000;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
    }

}