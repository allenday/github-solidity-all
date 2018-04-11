pragma solidity ^0.4.4;

contract basicInfoGetter {

	address creator;

	function basicInfoGetter()public{
		creator = msg.sender;
	}

  // get CURRENT block miner's address,
	function getCurrentMinerAddress()constant returns(address){ 
    return block.coinbase;
	}

	function getCurrentDifficulty()constant returns(uint) {
		return block.difficulty;
	}

	function getCurrentGaslimit()constant returns(uint){
		return block.gaslimit;
	}

	function getCurrentBlockNumber()constant returns(uint) {
		return block.number;
	}

	function getBlockTimestamp()constant returns(uint){
		return block.timestamp;
	}

	function getMsgData()constant returns(bytes){
		return msg.data;
	}

  // Returns the address of whomever made this call
	function getMsgSender()constant returns(address) { // (i.e. not necessarily the creator of the contract)
		return msg.sender;
	}

	function getMsgValue()constant returns(uint){
		return msg.value;
	}

	function getMsgGas()constant returns(uint) {
		return msg.gas;
	}

	function getTxGasprice()constant returns(uint){
		return tx.gasprice;
	}

  // returns sender of the transaction
	function getTxOrigin()constant returns(address){
		return tx.origin;
	}

	function getContractAddress()constant returns(address) {
		return this;
	}

	function getContractBalance()constant returns(uint) {
		return this.balance;
	}

	function kill() {
		if (msg.sender == creator)
			suicide(creator);
	}
}