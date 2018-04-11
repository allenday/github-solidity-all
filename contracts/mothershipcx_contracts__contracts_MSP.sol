pragma solidity ^0.4.11;

import "./MiniMeToken.sol";

/*
  Copyright 2017, Anton Egorov (Mothership Foundation)
*/

contract MSP is MiniMeToken {

  function MSP(address _tokenFactory)
    MiniMeToken(
                _tokenFactory,
                0x0,                // no parent token
                0,                  // no snapshot block number from parent
                "Mothership Token", // Token name
                18,                 // Decimals
                "MSP",              // Symbol
                true                // Enable transfers
                ) {}
}
