pragma solidity ^0.4.12;

contract RtcCoin {
	// This mapping holds the balances of all addresses that own RtcCoins
	mapping (address => uint256) public balances;

	// Initializes contract with initialSupply tokens
	function RtcCoin(uint256 initialSupply) {
		balances[msg.sender] = initialSupply;             // Give the creator all initial tokens
	}

	// Send coins
	function transfer(address to, uint256 value) {
		require(balances[msg.sender] >= value);           // Check if the sender has enough

		balances[msg.sender] -= value;                    // Subtract from the sender
		balances[to] += value;                            // Add to the recipient

        LogTransfer(msg.sender, to, value);               // Send a log event
	}

    event LogTransfer(address indexed from, address indexed to, uint value);
}
