pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/token/MintableToken.sol";

import "./DelegateDualOwnable.sol";


/**
 * DelegateDualOwnable is designed to override MintableToken ownership
 */
contract DualMintableToken is MintableToken, DelegateDualOwnable {
    function DualMintableToken(address ownerA, address ownerB) 
        public 
        DelegateDualOwnable(ownerA, ownerB) { }
}
