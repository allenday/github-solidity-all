pragma solidity ^0.4.8;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./BrehonContract.sol";

/// @title Brehon Contract Factory
contract BrehonContractFactory {

  mapping(bytes20 => BrehonContract) contracts;

  function BrehonContractFactory() {
  }

  function newBrehonContract(
      address partyA,
      address partyB,
      uint transactionAmount,
      bytes32 contractTermsHash,
      address primaryBrehon,
      uint primaryBrehonFixedFee,
      uint primaryBrehonDisputeFee,
      address secondaryBrehon,
      uint secondaryBrehonFixedFee,
      uint secondaryBrehonDisputeFee,
      address tertiaryBrehon,
      uint tertiaryBrehonFixedFee,
      uint tertiaryBrehonDisputeFee
  ) returns (BrehonContract brehonContractAddr) {
    brehonContractAddr = new BrehonContract(
        partyA,
        partyB,
        transactionAmount,
        contractTermsHash,
        primaryBrehon,
        primaryBrehonFixedFee,
        primaryBrehonDisputeFee,
        secondaryBrehon,
        secondaryBrehonFixedFee,
        secondaryBrehonDisputeFee,
        tertiaryBrehon,
        tertiaryBrehonFixedFee,
        tertiaryBrehonDisputeFee
    );
    bytes20 hash = ripemd160(msg.sender, contractTermsHash);
    contracts[hash] = brehonContractAddr;
  }

  function getBrehonContract(bytes32 contractTermsHash)
    returns (BrehonContract) {
    bytes20 hash = ripemd160(msg.sender, contractTermsHash);
    return contracts[hash];
  }
}
