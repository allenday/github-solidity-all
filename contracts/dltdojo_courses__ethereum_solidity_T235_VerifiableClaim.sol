pragma solidity ^0.4.14;
//
// Illinois Partners with Evernym to Launch Birth Registration Pilot 
// https://illinoisblockchain.tech/illinois-partners-with-evernym-to-launch-birth-registration-pilot-f2668664f67c
// 
// Verifiable Claims Data Model and Representations https://www.w3.org/TR/verifiable-claims-data-model/
// Blockcerts : The Open Initiative for Blockchain Certificates http://www.blockcerts.org/
// Chainpoint - Blockchain Proof & Anchoring Standard https://chainpoint.org/
// 

/*
EXAMPLE 3: A simple verifiable claim
{
  "@context": "https://w3id.org/security/v1",
  "id": "http://example.gov/credentials/3732",
  "type": ["Credential", "ProofOfAgeCredential"],
  "issuer": "https://dmv.example.gov",
  "issued": "2010-01-01",
  "claim": {
    "id": "did:example:ebfeb1f712ebc6f1c276e12ec21",
    "ageOver": 21
  },
  "revocation": {
    "id": "http://example.gov/revocations/738",
    "type": "SimpleRevocationList2017"
  },
  "signature": {
    "type": "LinkedDataSignature2015",
    "created": "2016-06-18T21:19:10Z",
    "creator": "https://example.com/jdoe/keys/1",
    "domain": "json-ld.org",
    "nonce": "598c63d6",
    "signatureValue": "BavEll0/I1zpYw8XNi1bgVg/sCneO4Jugez8RwDg/+
    MCRVpjOboDoe4SxxKjkCOvKiCHGDvc4krqi6Z1n0UfqzxGfmatCuFibcC1wps
    PRdW+gGsutPTLzvueMWmFhwYmfIFpbBu95t501+rSLHIEuujM/+PXr9Cky6Ed
    +W3JT24="
  }
}
*/

contract TestProofAge {
    function testRegisterAndVerified(){
        User alice = new User();
        alice.setAge(22);
        ProofOfAge poa = new ProofOfAge();
        poa.register(alice);
        require(poa.verifiedAgeOver(alice,21));
    }
}

contract User {
    uint public age = 0 ;
    function setAge(uint _age){
        age=_age;
    }
} 

contract ProofOfAge {

    mapping (address => uint) public ageMapping;

    function register(address _userAddress){
        User user = User(_userAddress);
        ageMapping[_userAddress] = user.age();
    }

    function verifiedAgeOver(address _userAddress, uint _ageOver) returns (bool) {
        User user = User(_userAddress);
        return user.age()>_ageOver;
    }
}

// TODO

// 1. User1 Create - setAge(18)
// 2. User2 Create - setAge(14)
// 3. ProofOfAge Create 
// 4. ProofOfAge.regiser(user1Address)
// 5. ProofOfAge.verifiedAgeOver(user1Address, 17)
//