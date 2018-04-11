
/*
Usage:
1.Account owner sends a request for verification, in this request he sends a fingerprint of his OpenPGP key verified by an accredited notary (from cryptonomica.net)
2.This contracts sends back a string to sign.
3.Account owner signs this string with his OpenPGP key and sends back to smart-contract.
4.Information about verification is public visible - who needs to check can download notary verified public key from cryptonomica.net and check if owner of stated Ehereum acconts is also known owner of notary verified OpenPGP key.
5. This can be used for legal binding contracts/smart-contracts - with arbitration clause according to IACC Arbitration Rules ( https://github.com/Cryptonomica/arbitration-rules )

It's also possible to create a web-inerface using Cryptonomica's API like:

GET https://cryptonomica-server.appspot.com/_ah/api/pgpPublicKeyAPI/v1/getPGPPublicKeyByFingerprint?fingerprint=57A5FEE5A34D563B4B85ADF3CE369FD9E77173E5

(Authorization required)

*/

import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract Verificator {

    string public creator;
    mapping (address => bytes32) public stringToSign;
    mapping (address => string) public signedString;
    mapping (address => string) public keyFingerprint;
    mapping (address => string) public urlToVerifyKey;
    string urlBase;

    function Verificator(){
        creator = "www.cryptonomica.net";
        urlBase = "https://cryptonomica.net/#/key/";
    }

    function getStringToSignWithKey(string _fingerprint) returns (bytes32) {

        keyFingerprint[msg.sender] = _fingerprint;
        urlToVerifyKey[msg.sender] = strings.concat(
                                        strings.toSlice(urlBase),
                                        strings.toSlice(_fingerprint)
                                    );

        var strToSign = sha3(
                msg.sender,
                block.blockhash(block.number),
                block.timestamp,
                block.blockhash(block.number - 250)
            );

        stringToSign[msg.sender] = strToSign;
        signedString[msg.sender] = "waiting to singed string";

        return stringToSign[msg.sender];
    }

    function uploadSignedString(string _signedString){

        signedString[msg.sender] = _signedString;
    }

}
