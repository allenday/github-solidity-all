pragma solidity ^0.4.12;


library Registry {
	/// @dev Party contract composed of the hash of contract bytecode.
	struct PartyContract {
		bytes32 hash;						// Hash of contract bytecode
		address party;						// Account party that submitted the address
		uint timestamp;						// Timestamp at time of creation of this contract (in seconds)
		State state;						// State of the contract
	}
}


/// @title Registry of contractual parties in the system. The registry allow for the validation of parties.
/// @author jeanturgeon
contract PartyRegistry {

	address private owner;					// Registry owner

	enum State {
		PENDING,							// Pending state of a PartyContract.
		ACTIVE,								// Active state of a PartyContract.
		INACTIVE,							// Inactive state of a PartyContract.
		REJECTED,							// Rejected state of a PartyContract.
		CANCELLED,							// Cancelled state of a PartyContract.
		LOCKED								// Locked state of a PartyContract.
	}

	/// @dev Dictionary that map hash to contract, i.e. registry.
	using Registry for Registry.PartyContract;
	mapping(bytes32 => Registry.PartyContract) public partycontracts;


	/// @dev General Constructor.
	function PartyRegistry() {
		owner = msg.sender;
	}


	/// @dev Check Identity is valid using modifier.
	/// @param identity Identity address to validate.
	/// @param registry Registry owner's address
	/// @return bool True if identity validate, false otherwise
	modifier checkIdentity(address identity, address registry) return (bool) {
		if (registry.isValid(identity) != 1) {
			throw;
		}
	}


	/**
	 * Ensure a permission where only the registry owner can initiate a change.
	 * Contract owner can interact as an anonymous third party by simply using
	 * another public key address.
	 *
	 * @param account Registry owner's address
	 * @return account Registry owner's address
	 */
	modifier onlyOwner(address account) {
		if (msg.sender != account) {
			throw;
			_;
		}
	}


	/**
	 *
	 */
	modifier inState(State _state) {
		require(state == _state);
		_;
	}

	/**
	 *
	 */
	modifier notNull(bytes32 hash) {
		if (bytes(hash).length == 0) {
			throw;
			_;
		}
	}


	/**
	 * @dev Only the registry owner can approve a party contract.
	 *
	 * @param contract Hash of the contract
	 * @param owner Registry owner's address
	 * @return bool True if successful, false otherwise
	 */
	function approve(bytes32 contract) onlyOwner(owner) returns(bool) {
		if (partycontracts[contract].hash) {
			var partycontract = partycontracts[contract];
			if (partycontract.hash != 0) {
				partycontract.state = State.ACTIVE;
				return true;
			}
			return false;
		}
		else {
			 throw; // non existant key
		}
	}


	/**
	 * Only the registry owner and original submitter can delete a contract.
	 * A contract in the rejected list cannot be removed.
	 *
	 * @param contract
	 * @return bool True if successful, false otherwise
	 */
	function delete(bytes32 contract) returns(bool) {
		if (partycontracts[contract].hash) {
			var partycontract = partycontracts[contract];
			if (partycontract.state != State.REJECTED
					&& partycontract.submitter == msg.sender
					&& msg.sender == owner) {
				delete partycontracts[contract];
				return true;
			}
			else {
				throw; // cannot reject contract
			}
		}
		else {
			 throw; // non existant key
		}
	}


	/**
	* This is the public registry function that contracts should use to check
	* whether a contract is valid. It's defined as a function, rather than .call
	* so that the registry owner can choose to charge based on their reputation
	* of managing good contracts in a registry.
	*
	* Using a function rather than a call also allows for better management of
	* dependencies when a chain forks, as the registry owner can choose to kill
	* the registry on the wrong fork to stop this function executing.
	 *
	 * @param contract
	 * @return bool True if successful, false otherwise
	*/
	function isValid(bytes32 contract) returns(bool) {
		if (partycontracts[contract].hash) {
			if (partycontracts[contract].state == State.ACTIVE) {
				return true;
			}
			else if (partycontracts[contract].state == State.REJECTED) {
				throw; // contract is rejected
			}
			else {
				return false;
			}
		}
		else {
			 throw; // non existant key
		}
	}


	/**
	 * Kill function to end the registry.
	 */
	function kill() onlyBy(owner) returns(uint) {
		selfdestruct(owner);
	}


	/**
	 * Only the registry owner can reject a contract.
	 */
	function reject(bytes32 contract) onlyOwner(owner) returns(bool) {
		if (partycontracts[contract].hash) {
			var partycontract = partycontracts[contract];
			partycontract.state = State.REJECTED;
			return true;
		}
		else {
			 throw; // non existant key
		}
	}


	/**
	 * Anyone can submit a party contract for acceptance into the registry.
	 *
	 * @param contract
	 * @return bool True if successful, false otherwise
	 */
	function submit(bytes32 contract) returns(bool) {
		if (partycontracts[contract].hash) {
			 throw; // duplicate key
		}
		else {
			// Add new to registry as pending.
			var partycontract = partycontracts[contract];
			partycontract.hash = contract;
			partycontract.party = msg.sender;
			partycontract.timestamp = block.timestamp;
			partycontract.state = State.PENDING;
			return true;
		}
	}
}
