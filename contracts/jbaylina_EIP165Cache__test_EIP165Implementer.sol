pragma solidity ^0.4.11;

import "../contracts/EIP165Cache.sol";

contract EIP165Implementer is IEIP165 {

    function EIP165Implementer() IEIP165() {
        supportsInterface[0x11111111] = true;
        supportsInterface[0x22222222] = true;
    }
}
