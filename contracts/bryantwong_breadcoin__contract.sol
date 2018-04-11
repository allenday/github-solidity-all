/* A solidity contract for a cryptocurrency named breadcoin, to be deployed 
 * on the ethereum blockchain.
 */


contract breadcoin {         
	//the token's name. For display purposes. 
	string public name;

	/* This creates an array with all balances */
	mapping (address => uint256) public balanceOf;   

	event Transfer(address sender, address receiver, uint amount);

	//initializes breadcoin, putting a given amount in the account of the creator. 
	function initializeBread(uint breadSupply, string tokenName) {
		coinBalanceOf[msg.sender] = breadSupply;		
		name = tokenName; 
	}

	//send bread to the given recipient from the caller. 
	function sendBread(address recip, uint amount) returns(bool sufficientFunds) {
		if(coinBalanceOf[msg.sender] < amount) { return false; }

		coinBalanceOf[msg.sender] -= amount;
		coinBalanceOf[recip] += amount;
		Transfer(msg.sender, recip, amount);
		return true;
	}	

	//prevents accidental sending of ether. 
	function() {
		throw;
	}


	/* proof of work */

	bytes32 public challenge = 'aaa aaa aaa aaa aaa aaa aaa aaa';
	uint public difficulty = 10**32; 

	function proofOfWork(uint guess) {
		bytes8 n = sha3(guess, challenge);
		if(n < difficulty) throw; //check if result under difficulty

		challenge = sha3(guess, challenge, block.blockhash(block.number)); //save hash for next challenge
		balanceOf[msg.sender] += 1;
	}


}
