contract BlockTubePrepaid {
	
	address validsender;
	bool public claimed;

	function BlockTubePrepaid(address _validsender){
		validsender = _validsender;
		claimed = false;
	}

	event Claimed(address _destination);

	// claim all fund of this contract
	function claim(address _destination){
		// if the caller is not the owner -> throw
		if (msg.sender != validsender) throw;
		// send all ether to claimer
		claimed = true;
		if (!_destination.send(this.balance)){
			throw;
		}
		Claimed(_destination);
	}
}
