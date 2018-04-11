pragma solidity ^0.4.4;
contract eAgreement { 
    function Sign() returns (string);
}

contract AgreementPen {
    eAgreement agreement;
    function AgreementPen(address contractAddress) {
        agreement = eAgreement(contractAddress);
    }
    
    function Sign() {
        agreement.Sign();
    }
 }