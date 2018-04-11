pragma solidity ^0.4.15;

import "./DualMintableToken.sol";

/**
 * Final token
 */
contract PBToken is DualMintableToken {

    string public constant name = "Pro Bono Coin";
    string public constant symbol = "PBC";
    uint8 public constant decimals = 18;

    function PBToken(address ownerA, address ownerB)
        public
        DualMintableToken(ownerA, ownerB) { }
}

