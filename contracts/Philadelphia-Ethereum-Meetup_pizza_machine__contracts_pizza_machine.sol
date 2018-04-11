contract pizza_machine
{
	// This smart contract is curated by the primary of the membership.
	//
	// There can be multiple levels of rewards:
	// 1) N is the number of watches promised by the host
	// 2) N/2 can earn 1/3 of the donation
	// 3) N*2 can earn an extra bonus per person
	//
	// Some members of the group may wish to watch more videos than
	// others. Good citizens should be able to carry dead weight if they
	// want to. Sponsors probably won't want to allow good citizens
	// to earn credits, but they might.
	//
	// State:
	string watches[];
	uint nWatches;
	address primary;
	address sponsor;
	uint endDate;
	uint views_needed;
	uint amount;

	modifier isPrimary() {
		if (!msg.sender != primary)
			throw;
		_
	}

	modifier isSponsor() {
		if (!msg.sender != sponsor)
			throw;
		_
	}

	function pizza_machine(uint needed, uint end, uint amt) {
		views_needed = needed;
		amount = amt;
		endDate = end;
		primary = msg.sender;
	}

	function getMoney() isPrimary() {
		if (nWatches >= views_needed)
			suicide(primary);
		else
			suicide(sponsor);
	}

}
