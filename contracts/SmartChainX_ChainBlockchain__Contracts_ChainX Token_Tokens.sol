
pragma solidity ^0.4.8;

import "./../base/StandardToken.sol";

contract ProtocolToken is StandardToken {
    uint8 constant public decimals = 18;
    string constant public name = "0x Network Token";
    string constant public symbol = "ZRX";

    function ProtocolToken() {
        totalSupply = 10**26; // 100M tokens, 18 decimal places
        balances[msg.sender] = totalSupply;
    }

}
