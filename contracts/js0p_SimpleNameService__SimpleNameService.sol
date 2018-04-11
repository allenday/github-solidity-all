pragma solidity ^0.4.9;

// Simple Ethereum smart contract to map hashes to addresses

contract SimpleNameService {

	address _owner;
	mapping(bytes32=>address) _mappings;
	
	event Setter(bytes32 hash, address addr);
    
    function SimpleNameService() {
        _owner = msg.sender;
    }
	
	// This is the function to be query the address mapped to a hash
	// It returns 0x0 if no address is mapped to the hash
    function get(bytes32 hash) constant returns (address) {
		return _mappings[hash];
    }
	
    function set(bytes32 hash, address addr) {
		
		bool allowed = false;
		
		if (_mappings[hash] == address(0x0)) {
			
			// The contract is "freed" if no owner is set, if that is ever needed
		    if (_owner == address(0x0) || _owner == msg.sender)
		         allowed = true;
		} else {
		
			// Once the a mapping is created, only the mapped address can change it
            if (_mappings[hash] == msg.sender)
                allowed = true;
		}
		
		if (allowed == true) {
            _mappings[hash] = addr;
			Setter(hash, addr);
		} else
			throw;
			
    }	
	
	function getOwner() constant returns (address) {
		return _owner;
	}	
	
	function setOwner(address newOwner) {
		
		// Only the owner of the contract can change the contract ownership
		if (_owner != msg.sender)
            throw;
		else
		    _owner = newOwner;
	}
	
}
