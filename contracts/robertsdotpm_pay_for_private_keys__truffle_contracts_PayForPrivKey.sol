pragma solidity ^0.4.8;

contract PayForPrivKey {
	// Begin config.
	uint constant min_blocks = 7;
	// End config.
	
	bool debug = true;
	address public pub_key;
	address public owner;
	uint deposit_amount;
	struct CommitInfo
	{
		bytes32 solution_hash;
		uint block_height; 
		bool is_valid;
    }
    
    uint public commit_no;
	mapping(uint => CommitInfo) public commitments;
	
	// Solution.
	struct Solution
	{
		bytes32 h1;
		uint8 v1;
		bytes32 r1;
		bytes32 s1;
		bytes32 h2;
		bytes32 s2;
		bool is_valid;
	}
	Solution public solution;
	
	uint start_chain_height;
	
	function PayForPrivKey(address _pub_key) payable
	{
		pub_key = _pub_key;
		owner = msg.sender; // Not used.
		deposit_amount = msg.value;
		start_chain_height = block.number;
	}
	
	function refund() public payable
	{
		// Expired - allow contract to be destroyed.
		if(block.number - start_chain_height >= min_blocks * 20 || debug)
		{
			if(msg.sender == owner)
			{
				suicide(owner);
			}
		}
	}
	
	function get_solution() public returns (bytes32, uint8, bytes32, bytes32, bytes32, bytes32, bool){
		return (solution.h1, solution.v1, solution.r1, solution.s1, solution.h2, solution.s2, solution.is_valid);
	}
	
	function get_commit_no() public returns (uint){
		return commit_no;
	}
	
	function toBytes(address x) returns (bytes b) {
		b = new bytes(20);
		for (uint i = 0; i < 20; i++)
			b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
	}
    
	function CommitSolutionHash(bytes32 _solution_hash) public returns (uint)
	{
		// Don't allow new submissions after a certain timeout.
		if(block.number - start_chain_height >= min_blocks * 10 && !debug)
		{
			throw;
		}
		
		commit_no = commit_no++;
		commitments[commit_no] = CommitInfo(_solution_hash, block.number, true);
	
		return commit_no;
	}
	
	function ProvePrivKey(bytes32 h1, uint8 v1, bytes32 r1, bytes32 s1, bytes32 h2, bytes32 s2, address destination, uint index) public payable returns(address)
	{
		// Don't allow new submissions after a certain timeout.
		if(block.number - start_chain_height >= min_blocks * 10 && !debug)
		{
			throw;
		}
		
	    // Check this is a commitment first.
	    bytes32 solution_hash = sha3(h1, v1, r1, s1, h2, s2, toBytes(destination));	    
	    if(commitments[index].solution_hash != solution_hash)
	    {
			throw;
	    }
	    
	    // Now this is important -- check enough block have passed since the commitment was made.
	    // This is necessary for security reasons (race conditions from malicious observers)
	    if(block.number - commitments[index].block_height < min_blocks && !debug)
	    {
	        throw;
	    }
	    
		// Sig values must be unique.
		if(s1 == s2)
		{
			throw;
		}
		
		// Hash values must be unique.
		// Well they should be if s* is but we'll check anyway.
		if(h1 == h2)
		{
			throw;
		}
		
		// Recover the first public key and check it.
		address pub_key_1 = ecrecover(h1, v1, r1, s1);
		if(pub_key_1 == 0x0)
		{
			throw;
		}
		
		// Recover the second public key and check it.
		address pub_key_2 = ecrecover(h2, v1, r1, s2);
		if(pub_key_2 == 0x0)
		{
			throw;
		}
		
		// Check recovered public key is for the target key.
		if(pub_key_1 == pub_key_2 && pub_key_2 == pub_key)
		{
			// Send the Ether to their provided address.
			if(!destination.send(deposit_amount))
			{
			    throw;
			}
			
			// Save solution.
			solution.v1 = v1;
			solution.r1 = r1;
			solution.h1 = h1;
			solution.h2 = h2;
			solution.s1 = s1;
			solution.s2 = s2;
			solution.is_valid = true;
			
			return pub_key_1;
		}
		else
		{
			throw;
		}
	}
	
}
