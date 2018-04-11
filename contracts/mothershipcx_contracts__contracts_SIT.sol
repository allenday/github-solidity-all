pragma solidity ^0.4.11;

import "./MiniMeToken.sol";

/*
  Copyright 2017, Anton Egorov (Mothership Foundation)
*/

contract SIT is MiniMeToken {

  function SIT(address _tokenFactory)
    MiniMeToken(
                _tokenFactory,
                0x60f3c7c45933d9cfae0c6950190d8c95543a4576, // no parent token
                block.number,                               // no snapshot block number from parent
                "Strategic Investor Token",                 // Token name
                18,                                         // Decimals
                "SIT",                                      // Symbol
                false                                       // Enable transfers
                ) {}
}
