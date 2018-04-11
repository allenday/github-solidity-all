contract BlockTubePrepaid {
	
	address owner;

	function BlockTubePrepaid(){
		owner = msg.sender;
	}

	event Claimed(address _claimer);

	// claim all fund of this contract
	function claim(address _claimer){
		// if the caller is not the owner -> throw
		if (msg.sender != owner) throw;
		// send all ether to claimer
		_claimer.send(this.balance);
		Claimed(_claimer);
	}
}
