contract SimpleAuction {
	// parameters
	address public beneficiary;
	uint public auctionStart;
	uint public biddingTime;

	// current states
	address public highestBidder;
	uint public highestBid;

	// disallow changes at end
	bool ended;

	// events that will be fired on changes
	event HighestBidIncreased(address bidder, uint amount);
	event AuctionEnded(address winner, uint amount);

	/// Create a simple auction with '_biddingTime'
	/// seconds bidding time on behalf of the
	/// beneficiary address '_beneficiary'.
	function SimpleAuction(uint _biddingTime, address _beneficiary) {
		beneficiary = _beneficiary;
		auctionStart = now;
		biddingTime = _biddingTime;
	}

	/// Bid on the auction with the value sent
	/// together with this transaction.
	/// The value will only be refunded if the
	/// auction is not won.
	function bid() {
		if (now > auctionStart + biddingTime) {
			throw;
		}
		if (msg.value <= highestBid) {
			throw;
		}
		if (highestBidder != 0) {
			highestBidder.send(highestBid);
		}
		highestBidder = msg.sender;
		highestBid = msg.value;
		HighestBidIncreased(msg.sender, msg.value);
	}

	/// End the auction and send the highest bid
	/// to the beneficiary.
	function auctionEnd() {
		if (now <= auctionStart + biddingTime) {
			throw;
		}
		if (ended) {
			throw;
		}
		AuctionEnded(highestBidder, highestBid);
		beneficiary.send(this.balance);
		ended = true;
	}

	// executed on invalid situation
	function () {
		throw;
	}
}
