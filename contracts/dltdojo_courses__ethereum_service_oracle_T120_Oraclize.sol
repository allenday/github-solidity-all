pragma solidity ^0.4.14;

// http://dapps.oraclize.it/browser-solidity/

// Oraclize is hosting a patched version of the Remix IDE. 
// The patch adds a plugin enabling testing of Ethereum Oraclize-based contracts directly from the browser
// the contract can be deployed in memoryand the request is resolved automatically via the Oraclize HTTP API.

// Oraclize Documentation https://docs.oraclize.it/#ethereum-quick-start
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract ExampleContract is usingOraclize {

    string public EURGBP;
    event updatedPrice(string price);
    event newOraclizeQuery(string description);

    function ExampleContract() payable {
        updatePrice();
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        EURGBP = result;
        updatedPrice(result);
    }

    function updatePrice() payable {
        if (oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(http://api.fixer.io/latest?symbols=USD,GBP).rates.GBP");
        }
    }
}

// TODO
// oraclize_query("WolframAlpha", "random number between 0 and 100");
// parseInt(result);

contract RandomContract is usingOraclize {
    uint public randomInt;
    // TODO
}