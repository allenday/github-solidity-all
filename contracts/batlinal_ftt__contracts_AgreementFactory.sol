pragma solidity ^0.4.4;

import "./ServiceAgreement.sol";

/* Used to create the ServiceToken and acts as digital signiture for legal docs */
contract AgreementFactory {
  event Agreement(ServiceAgreement agreement, address indexed creator, address indexed issuer, address indexed beneficiary);

  ServiceAgreement[] public agreements; // Stores the registry of agreements

  function createAgreement(
    string name,
    string symbol,
    uint8 decimals,
    uint256 totalSupply,
    uint validFrom,
    uint expiresEnd,
    address issuer,
    address beneficiary,
    uint256 price
    ) {

    ServiceAgreement agreement = new ServiceAgreement(
      name, symbol, decimals, totalSupply, validFrom,
      expiresEnd, issuer, beneficiary, price);

    agreements.push(agreement);
    Agreement(agreement, msg.sender, issuer, beneficiary);
  }

  function getAgreements() returns (ServiceAgreement[] _agreements) {
    return agreements;
  }
}
