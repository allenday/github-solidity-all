// This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20)
// You can find more complex example in https://github.com/ConsenSys/Tokens 
pragma solidity ^0.4.8;

import "./BaseToken.sol";

contract UsableToken is BaseToken {

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'U1';

    function UsableToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[this] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }
    
    function claim() returns (bool success) {
        require(balances[msg.sender] < balances[this] / 1000);
        uint256 value = balances[this] / 10000;
        balances[msg.sender] += value;
        balances[this] -= value;
        Transfer(this, msg.sender, value);
        return true;
    } 
}