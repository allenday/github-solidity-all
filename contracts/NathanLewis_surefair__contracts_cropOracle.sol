pragma solidity ^0.4.10;

contract CropOpracle {

    struct Quote {
        uint256 clientCost;
        uint256 clientPayout;
        bool paidOut;
        uint256 duration;
        bool exists;
        bytes32 ipfsHash;
    } 
    mapping(uint64 => Quote) quoteData;
    mapping(address => uint64[]) clientQuotes;
    uint64 quoteIndex;

    address creator;

    function CropOracle(address creator) {
        creator = msg.sender;
    }

    function getOracleDetails() constant returns (string, string) {
        return ("Crop Insurance", "An oracle to issue crop insurance.");
    }

    function getUserQuoteIds(address _client) constant returns (uint64[]) {
        return clientQuotes[_client];
    }
    
    function getQuote(address _client, uint64 _quoteId) constant returns (uint256, uint256, uint256, bytes32) {
         Quote quote = quoteData[_quoteId];
         return (quote.clientCost, quote.clientPayout, quote.duration, quote.ipfsHash);
    }

    function createQuote(uint256 gpsLat, uint256 gpsLong, bytes32 _ipfsHash ) returns (uint64) 
    { 
        Quote memory newQuote;
        if ((gpsLat/10 < 20 && gpsLat/10 > 10 && gpsLong/10 > 30 && gpsLong/10 < 35)) {
            newQuote.clientCost = 1000;
            newQuote.clientPayout = 2000;
        }
        else
        {
            newQuote.clientCost = 100;
            newQuote.clientPayout = 3000;
        }

        newQuote.duration = 1000;
        newQuote.exists = true;
        newQuote.ipfsHash = _ipfsHash;
        
        uint64 userQuoteIndex = quoteIndex;
        quoteData[userQuoteIndex] = newQuote;
        clientQuotes[msg.sender].push(userQuoteIndex);
        quoteIndex++;
        return userQuoteIndex;
    }

    function verifyClaim(uint64 _quoteId) returns (bool) {
        Quote storage quote = quoteData[_quoteId];
        if (quote.exists) {
            return true; //what a generous oracle, claims are always valid!
        }
        return false;
    }
}