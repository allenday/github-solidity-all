ragma solidity ^0.4.8;

import "./../base/StandardToken.sol";
import "./../base/SafeMath.sol";

/*
 * Mintable
 * Base contract that creates a mintable StandardToken
 */
contract Mintable is StandardToken, SafeMath {
    function mint(uint _value) {
        if (_value > 100000000000000000000) {
            throw;
        }
        balances[msg.sender] = safeAdd(_value, balances[msg.sender]);
        totalSupply = safeAdd(totalSupply, _value);
    }
}
