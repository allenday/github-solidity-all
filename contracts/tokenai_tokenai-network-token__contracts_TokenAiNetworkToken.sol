pragma solidity ^0.4.14;

import "./MiniMeToken.sol";
import "./VestedToken.sol";

contract TokenAiNetworkToken is MiniMeToken, VestedToken {
    function TokenAiNetworkToken(address _controller, address _tokenFactory)
        MiniMeToken(
            _tokenFactory,
            0x0,                        // no parent token
            0,                          // no snapshot block number from parent
            "TokenAI Netwok Token",     // Token name
            18,                         // Decimals
            "TAI",                      // Symbol
            true                        // Enable transfers
            )
    {
        changeController(_controller);
    }
}
