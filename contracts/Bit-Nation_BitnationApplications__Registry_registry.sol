pragma solidity ^0.4.0;

contract BitnationRegistry {
	struct Vote {
	    address voter;
	    address target;
		bool support;
		string justification;
	}

	struct ContractMeta {
		address owner;

		string name;
		string info_link;
		string description;

		// To check if someone already voted
		mapping (address => bool) voted;

		// There are no scores calculated here, because Bitbot will handle that
	}
	
	int public number_of_contracts;
	int public number_of_votes;
	
	// List all the votes so Bitbot can read them
	Vote[] public votes;

	// List of all the registered contracts
	address[] public contracts;
	
	// Contracts informations and votes
	mapping (address => ContractMeta) public contracts_info;

	event ContractAdded(address contract_addr, address owner);
	event NewVote(address voter, bool support, string justification, address target);

	function submit(address contract_addr, string name, string info_link, string description) {
		// If it is already registered, the owner address is different from 0
		if (contracts_info[contract_addr].owner != address(0) || contract_addr == address(0)) throw;

		ContractMeta meta = contracts_info[contract_addr];
		meta.owner = msg.sender;
		meta.name = name;
		meta.info_link = info_link;
		meta.description = description;

		contracts.push(contract_addr);

        number_of_contracts += 1;

		ContractAdded(contract_addr, msg.sender);
	}

	function vote(address target, bool support, string justification) {
		// If the target doesn't exist (owner is 0) or the sender already voted
		if (contracts_info[target].owner == address(0) || contracts_info[target].voted[msg.sender]) throw;
		
		// "Register" the vote
		contracts_info[target].voted[msg.sender] = true;
		
		// Create and push it for BitBot
		votes.push(Vote({support: support, justification: justification, voter: msg.sender, target: target}));

        number_of_votes += 1;

		NewVote(msg.sender, support, justification, target);
	}
}

