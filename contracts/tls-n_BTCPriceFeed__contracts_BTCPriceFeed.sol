pragma solidity ^0.4.1;

import "./imported/JsmnSolLib.sol";
import "./imported/bytesutils.sol";
import "./imported/tlsnutils.sol";


contract BTCPriceFeed {
    using bytesutils for *;

	// Mapping from timestamp to BTC price in USD cents (= 10**-2 USD)
    mapping(uint32 => uint32) timestamp_to_price;

	// Perform parsing of result using JsmnSolLib
	// Returns: opening timestamp, opening price, closing timestamp, closing price
    function parseBitcoinComFeed(string json) external returns(uint32 timestamp0, uint32 price0, uint32 timestamp1, uint32 price1){
        uint res;
		string memory val;
        JsmnSolLib.Token[] memory tokens;
        JsmnSolLib.Token memory t;
        uint num_tokens;
		// Parse JSON
        (res, tokens, num_tokens) = JsmnSolLib.parse(json, 50);
        require(res == 0);

		// Find opening tag
        t = tokens[1];
        val = JsmnSolLib.getBytes(json, t.start, t.end);
		require(JsmnSolLib.strCompare(val, "open") == 0);

		// Ensure price is in result
        t = tokens[3];
        val = JsmnSolLib.getBytes(json, t.start, t.end);
		require(JsmnSolLib.strCompare(val, "price") == 0);

		// Read start price of the day
        t = tokens[4];
        price0 = uint32(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, t.start, t.end)));
		require(price0 > 0);

		// Read time tag 
        t = tokens[5];
        val = JsmnSolLib.getBytes(json, t.start, t.end);
		require(JsmnSolLib.strCompare(val, "time") == 0);

		// Ensure time is unix timestamp
        t = tokens[7];
        val = JsmnSolLib.getBytes(json, t.start, t.end);
		require(JsmnSolLib.strCompare(val, "unix") == 0);

		// Get opening timestamp
        t = tokens[8];
        timestamp0 = uint32(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, t.start, t.end)));
		require(timestamp0 > 0);

		// Get closing tag
        t = tokens[11];
        val = JsmnSolLib.getBytes(json, t.start, t.end);
		require(JsmnSolLib.strCompare(val, "close") == 0);

		// Get price tag
        t = tokens[13];
        val = JsmnSolLib.getBytes(json, t.start, t.end);
		require(JsmnSolLib.strCompare(val, "price") == 0);

		// Get closing price
        t = tokens[14];
		price1 = uint32(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, t.start, t.end)));
		require(price1 > 0);
 
		// Get time tag
        t = tokens[15];
        val = JsmnSolLib.getBytes(json, t.start, t.end);
		require(JsmnSolLib.strCompare(val, "time") == 0);

		// Ensure time is unix timestamp
        t = tokens[17];
        val = JsmnSolLib.getBytes(json, t.start, t.end);
		require(JsmnSolLib.strCompare(val, "unix") == 0);

		// Get closing timestamp
        t = tokens[18];
        timestamp1 = uint32(JsmnSolLib.parseInt(JsmnSolLib.getBytes(json, t.start, t.end)));
		require(timestamp1 > 0);

    }
 

	// Function that allows proof submission
    function submitProofOfPrice(bytes memory proof){
        // Check if proof is valid
        // Elliptic curve parameters for the TLS certificate of tls-n.org
        uint256 qx = 0x0de2583dc1b70c4d17936f6ca4d2a07aa2aba06b76a97e60e62af286adc1cc09;
        uint256 qy = 0x68ba8822c94e79903406a002f4bc6a982d1b473f109debb2aa020c66f642144a;
        require(tlsnutils.verifyProof(proof, qx, qy));

        // Check HTTP Request
        bytes memory request = tlsnutils.getHTTPRequestURL(proof);
        // Check that the first part is correct 
        require(request.toSlice().startsWith("/proxy.py?url=https%3A//index.bitcoin.com/api/v0/lookup%3Ftime%3D".toSlice()));
        // Check that the second part is not too long
        require(request.toSlice().find("%3D".toSlice()).len() == 13);

        // Check the host (kind of redundant due to signature check) 
        bytes memory host = tlsnutils.getHost(proof);
        require(host.toSlice().equals("tls-n.org".toSlice()));

        // Get the body
        bytes memory body = tlsnutils.getHTTPBody(proof);

        uint32 timestamp0;
        uint32 price0;
        uint32 timestamp1;
        uint32 price1;
		// Parse the timestamps
        (timestamp0, price0, timestamp1, price1) = this.parseBitcoinComFeed(string(body));
		// Insert the timestamps
        timestamp_to_price[timestamp0] = price0; 
        timestamp_to_price[timestamp1] = price1; 
    }

	// Request a securely inserted price
	// Throws if no price found for given timestamp
	function getPrice(uint32 timestamp) returns (uint32){
		uint32 price = timestamp_to_price[timestamp];
		// Make sure this mapping element exists
		require(price > 0);
		return price;
	}
}

