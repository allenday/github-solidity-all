contract autoJudge {
	uint pot;
	uint ticketPrice;
	uint difficulty;
	address creator;
	address betfundingAddress;
	uint idProject;
	
	function autoJudge() {
		pot = 0;
		ticketPrice = 0;
		difficulty = 0;
		creator = msg.sender;
		idProject = 0;
	}
	
	function setNumNumbers(uint n) {
		if(msg.sender == creator && difficulty == 0)
			difficulty = n;
	}
	
	function setPrice(uint price) {
		if(msg.sender == creator && ticketPrice == 0)
			ticketPrice = price;
	}
	
	function setProjectToVerify(address betfunding, uint id) {
		if(msg.sender == creator && idProject == 0){
			betfundingAddress = betfunding;
			idProject = id;
		}
	}
	
	function buyTicket(uint nonce){
		if(msg.value >= ticketPrice && ticketPrice > 0 && idProject != 0 && difficulty > 0){
			
			pot += msg.value;
			
			uint ticket = uint(sha256(block.timestamp, nonce, msg.sender)) % difficulty;
			uint winnerTicket = uint(sha256(block.blockhash(block.number), nonce, msg.sender)) % difficulty;
			
			if(ticket == winnerTicket){
				address winner = msg.sender;
				
				betfundingAddress.call("verifyProject", idProject);
				suicide(winner);
			}			
		}		
	}
	
	function getPot() constant returns (uint r){
		
		return pot;
	}
	
	function getTicketPrice() constant returns (uint r){
		
		return ticketPrice;
	}
	
	function getDifficulty() constant returns (uint r){
		
		return difficulty;
	}
	
	function getBetfundingAddress() constant returns (address r){
		
		return betfundingAddress;
	}
	
	function getIdProject() constant returns (uint r){
		
		return idProject;
	}
}