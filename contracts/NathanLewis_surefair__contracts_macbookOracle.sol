pragma solidity ^0.4.10;

contract MacBookOracle {

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

    function MacBookOracle() {
        creator = msg.sender;
    }

    function getOracleDetails() constant returns (string, string) {
        return ("Macbook Insurance", "A Macbook oracle designed exclusively to insure macbooks created between 2016 and 2017.");
    }

    function getUserQuoteIds(address _client) constant returns (uint64[]) {
        return clientQuotes[_client];
    }

    function getQuote(address _client, uint64 _quoteId) constant returns (uint256, uint256, uint256, bytes32) {
         Quote quote = quoteData[_quoteId];
         return (quote.clientCost, quote.clientPayout, quote.duration, quote.ipfsHash);
    }

    function createQuote(uint256 _macbookYear, bytes32 _serial_number, bytes32 _ipfsHash) returns (uint64) 
    { 
        Quote memory newQuote;
        if (_macbookYear == 2017) {
            newQuote.clientCost = 100;
            newQuote.clientPayout = 2000;
        }
        if (_macbookYear == 2016) 
        {
            newQuote.clientCost = 90;
            newQuote.clientPayout = 1800;
        }
        else{
            newQuote.clientCost = 10;
            newQuote.clientPayout = 100;
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