pragma solidity ^0.4.11;

import "./Owned.sol";

contract CurrencyHedge is Owned {
    struct Hedge {
        address beneficiary;
		uint hedgeStart;		// Seconds in Unix Epoch (since Jan 1, 1970)
        uint hedgeEnd;			// Seconds in Unix Epoch
        bytes3 homeCurr;    	// Denoted with three letters (e.g. USD, EUR)
        bytes3 hedgeCurr;

		// Rates will be evaluated up to 5 decimal points, and so must be
        // multiplied by 10^5 to be stored as an integer value.
        uint64 refRate;

        bytes32 instID;     	// Institution identifier
        bytes32 acctID; 		// ID of account associated with institution
        bool active;			// Hedge contract state (active or expired?)
    }

    struct Transaction {
		// This struct will eventually need a way to check that the purchase made
		// by the client is actually covered by the hedge (e.g. client made the
		// purchase in Thailand for a Thai hedge and not in, say, New Zealand)
        uint timeStamp;       	// Seconds in Unix Epoch
        uint64 txValue;			// Transaction value in home currency
        uint64 rateDiff;		// Difference between spot exchange rate at time of transaction and hedge's reference rate
    }

	// Create a global list of all hedges
	// NOTE: This implies that hedgeTx will also be public, which it probably shouldn't be
	Hedge[] public allHedges;

	// Solidity cannot return structs, and can only return arrays of addresses, bools, or uints
	mapping (address => uint256[]) private hedgeIndices;

    // Reverse mapping of indices to addresses for easy verification
    mapping (uint256 => address) private hedgeBeneficiaries;

    // Mapping of Hedge indices to arrays of Transactions.  This must be used because Solidity does weird
    // things when a struct array is nested inside another struct
	// Refer to https://ethereum.stackexchange.com/questions/3525/how-to-initialize-empty-struct-array-in-new-struct
    mapping (uint256 => Transaction[]) private allTx;

    // CurrencyHedge: Contract creator.
    function CurrencyHedge() {
        owner = msg.sender;
    }

	// addHedge: Add a new hedge to the book
	function addHedge(address _beneficiary, uint _hedgeStart, uint _hedgeEnd, bytes3 _homeCurr,
		bytes3 _hedgeCurr, uint64 _refRate, bytes32 _instID, bytes32 _acctID) public onlyOwner {

		require(_hedgeEnd - _hedgeStart >= 604800);		// Enforce minimum hedge period of 7 days = 604,800 seconds

		// Create a new hedge and populate the information.
		Hedge memory newHedge = Hedge(_beneficiary, _hedgeStart, _hedgeEnd, _homeCurr, _hedgeCurr, _refRate, _instID, _acctID, false);

		// Add the hedge to the global list, and associate the index of the hedge with the beneficiary
		allHedges.push(newHedge);
        uint newIndex = allHedges.length - 1;
		hedgeIndices[_beneficiary].push(newIndex);
        hedgeBeneficiaries[newIndex] = _beneficiary;
	}

	// getHedgeIndices: Retrieve a list of indices of the allHedges array associated with a particular beneficiary's
	// Refer to https://ethereum.stackexchange.com/questions/3589/how-can-i-return-an-array-of-struct-from-a-function
	function getHedgeIndices(address _beneficiary) public onlyOwner returns (uint256[]) {
		return hedgeIndices[_beneficiary];
	}

	// getNumberOfTx: Retrieve the number of transactions currently associated with a given hedge
	function getNumberOfTx(uint _index) public onlyOwner returns (uint) {
		return allTx[_index].length;
	}

	// activateHedge: Activate a hedge and allow transactions to be recorded to it
	function activateHedge(address _beneficiary, uint256 _index) public onlyOwner {
        require(hedgeBeneficiaries[_index] == _beneficiary);    // Check that the specified index and beneficiary are associated
        require(!allHedges[_index].active);				// Check that the hedge is currently inactive

		// This should be verified outside of the contract.  'now' is an alias for
		// block.timestamp, not current time
		require(allHedges[_index].hedgeEnd < now);		// Don't reactivate a dead hedge
		require(allHedges[_index].hedgeStart >= now);	// Don't prematurely activate a hedge

		allHedges[_index].active = true;
	}

	// deactivateHedge: Deactivate a hedge and prevent any new data from being added
	function deactivateHedge(address _beneficiary, uint256 _index) public onlyOwner {
        require(hedgeBeneficiaries[_index] == _beneficiary);    // Check that the specified index and beneficiary are associated
		require(allHedges[_index].active);				// Check that the hedge is currently active

		// This should be verified outside of the contract.  'now' is an alias for
		// block.timestamp, not current time
		require(allHedges[_index].hedgeEnd >= now);		// Don't prematurely deactivate a hedge

		allHedges[_index].active = false;
	}

	// recordTransaction: Add a transaction record to a particular hedge
	function recordTransaction(address _beneficiary, uint256 _index, uint64 _timeStamp, uint64 _txValue,
		uint64 _spotRate) public onlyOwner {

        require(hedgeBeneficiaries[_index] == _beneficiary);    // Check that the specified index and beneficiary are associated
		require(allHedges[_index].active);       // Check that the hedge is currently inactive

		// This should be verified outside of the contract.  'now' is an alias for
		// block.timestamp, not current time
		require(allHedges[_index].hedgeEnd <= now);

		Transaction memory newTx = Transaction(_timeStamp, _txValue, _spotRate - allHedges[_index].refRate);
		allTx[_index].push(newTx);
	}

	// endContract: Close out the hedge and pay whatever is needed to the beneficiary
	function endContract(address _beneficiary, uint256 _index) public payable onlyOwner {
        require(hedgeBeneficiaries[_index] == _beneficiary);    // Check that the specified index and beneficiary are associated
		require(!allHedges[_index].active);       // Check that the hedge is currently inactive
        require(allTx[_index].length > 0);      // Check that the list of transactions is greater than zero

        // Calculate the value of the payout to the beneficiary
		uint totalPayout = 0;
		for (uint256 i = 0; i < allTx[_index].length; i++) {
			if (allTx[_index][i].rateDiff > 0)
				totalPayout += allTx[_index][i].txValue * allTx[_index][i].rateDiff;
		}

		// Deactivate the hedge
		deactivateHedge(_beneficiary, _index);
		_beneficiary.transfer(totalPayout);
	}
}
