pragma solidity ^0.4.8;

import "./InsuranceToken.sol";
import "./Verifiable.sol";

//
// Master contract through which Insurance Company creates and tracks all Insurance contracts.
//
contract InsuranceMasterContract is Verifiable {
    address owner;
    mapping(address => bool) tokensByAddress;
    mapping(string => bool) tokensBySymbol;

    function InsuranceMasterContract() {
        owner = msg.sender;
    }

    function createNew(string icoSymbol) {
        address token = new InsuranceToken();
        tokensByAddress[token] = true;
        tokensBySymbol[icoSymbol] = true;
    }

    function validateBySymbol(string icoSymbol) constant returns (bool) {
        return tokensBySymbol[icoSymbol];
    }
    function verify(address icoTokenAddr) constant returns (bool ok) {
        return tokensByAddress[icoTokenAddr];
    }
}