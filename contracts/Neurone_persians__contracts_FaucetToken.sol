pragma solidity ^0.4.18;

import "./SimpleToken.sol";
import "./SafeMathLib.sol";

contract FaucetToken is SimpleToken {
    using SafeMathLib for uint256;

    function FaucetToken(string _name, string _symbol, uint8 _decimals) SimpleToken(_name, _symbol, _decimals, 2**256 - 1) public { }

    function getTokens(uint256 _amount) public {
        balances[owner] = balances[owner].sub(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
    }

}