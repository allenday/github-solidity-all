pragma solidity ^0.4.2;

import "./RVRControlled.sol";

contract RVRCoin is RVRControlled { 		//Smart Contract wordt aangemaakt

	mapping (address => uint) balances;		//Elk blockchain adres krijgt een balans

	address owner;												//Het adres van de eigenaar
	uint start = 100;											//Een standaard aantal punten
	uint total_coins = 0;									//Totale hoeveelheid punten

	event deductSuccesful(address lawyer, uint256 _value);

	//Punten aftrek moet aan voorwaarden voldoen: een advocaat moet balans hebben
	modifier hasBalance(address lawyer, uint deduction) {
		if (balances[lawyer] - deduction < 0 ) {
			balances[lawyer] = 0;
			throw;
		}
		_;
	}

	function RVRCoin() {
		balances[tx.origin] = start;			//De maker van het contract krijgt punten
		owner = tx.origin;								//De maker van het contract wordt eigenaar
	}

	function defaultWallet(address lawyer) {
		balances[lawyer] = start;					//Een nieuwe advocaat krijgt punten
		total_coins += start;							//Het totale aantal punten gaat omhoog
	}

	function deductCoin(address lawyer, uint amount) hasBalance(lawyer, amount) {
		balances[lawyer] = balances[lawyer] - amount;	//Punten worden afgetrokken
		total_coins -= amount;												//Punten worden afgetrokken
		deductSuccesful(lawyer, amount);					//Een bericht wordt uitgezonden
	}

	function getBalance(address lawyer) returns(uint) {
		return balances[lawyer];					//Haalt de balans op van een advocaat
	}

	function getTotalBalance() returns(uint) {
		return total_coins;								//Haalt het totaal aan punten op
	}

}
