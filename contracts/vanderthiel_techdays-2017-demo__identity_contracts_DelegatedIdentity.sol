pragma solidity ^0.4.4;

contract DelegatedIdentity {
    // for agent access
    address agent;

    // Any public keys
    mapping (address => bytes32) publicKeys;

    // And all available claims, traceable
    mapping (string => address) claims;

    // Constructor
    function DelegatedIdentity(address delegate) public {
        agent = delegate;
    }

    // As an authorizer, add a claim
    function addClaim(string claim) public {
        claims[claim] = msg.sender;
    }

    // As a requester that obtained a public key, check a claim
    function checkClaim(string publicKey, string claim) public view returns (address authority) {
        if (sha256(publicKey) == publicKeys[msg.sender]) {
            return claims[claim];
        }
    }

    // if you know the private key with which it was created, you can add a requester
    function addRequester(address requester, string publicKey) public {
        if (msg.sender == agent) {
            publicKeys[requester] = sha256(publicKey);
        }
    }
}