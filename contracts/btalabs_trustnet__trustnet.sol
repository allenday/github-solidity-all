contract trustNet {
	//a register of claims (descriptive statements about an entity)
	//a universal reputation system
	//author @hugooconnor
	//license GNU GPL
	//(this code is currently a sketch -- ie. not working :)

	struct claim {
		//id of the claim
		bytes32 id;
		//who is making the claim
		address owner;
		//who or what the claim is about
		bytes32 target;
		//ipfs hash to related documents
		string ipfsHash;
		//categorycode - defined by trustnet owner and admins
		uint categoryCode;
		//as per ISO 3166-1 and ISO 3166-2
		bytes32 countryCode;
		//dates between which the claim is valid
		uint startDate;
		uint endDate;
		//degree of confidence in the claim - 256 == full confidence
		uint8 confidence;
		//blocktime of the claim
		uint dateCreated;
	}

	struct categoryCode {
		address owner;
		string definition;
		uint dateCreated;
		uint dateModified;
	}

	//main data structure --  tying bytes32 identifier to an array of claims
	mapping (bytes32 => claim[]) claimRegister;
	//category code data structure - tying numbers to definitions
	mapping (uint => categoryCode) codeRegister;
	//admin register -- who has permission to edit the category codes;
	mapping (address => bool) adminRegister;
	//creator of the trustnet
	address owner;

	event makeClaimLog();
	event withdrawClaimLog();

	event makeCodeLog();
	event editCodeLog();
	
	event makeAdminLog();
	event revokeAdminLog();

	// --- TRUSTNET ---

	function trustNet(){
		owner = msg.sender;
	}

	// --- CLAIMS  ---

	function makeClaim(
						bytes32 _target,
	 					string _ipfsHash,
	 					uint _categoryCode,
	 					bytes32 _countryCode,
	 					uint _startDate,
	 					uint _endDate,
	 					uint8 _confidence,
	 					uint _dateCreated)

 				returns (bytes32 id) {

		bytes32 _id = sha3(
						 msg.sender,
						 _target,
						 _ipfsHash,
						 _categoryCode,
						 _countryCode,
						 _startDate,
						 _endDate,
						 _confidence,
						 block.timestamp);

		claimRegister[_target].push(
					claim(
						 _id,
						 msg.sender,
						 _target,
						 _ipfsHash,
						 _categoryCode,
						 _countryCode,
						 _startDate,
						 _endDate,
						 _confidence,
						 block.timestamp));
		makeClaimLog();
		return _id;
	}

	function getClaims(string target) returns (claim[] claims) { 
		return claimRegister[target];
	}

	// --- CODE CATEGORY  ---

	function makeCode(uint _id, string definition) {
		//anyone can make a new code if the code is not already taken
		if(codeRegister[_id] == 0x0){
			codeRegister[_id].owner = msg.sender;
			codeRegister[_id].definition = definition;
			codeRegister[_id].dateCreated = block.timestamp;
			makeCodeLog();
		}	

	}

	function editCode(uint _id, string definition) {
		//only admins can modifiy a code definition
		if(codeRegister[_id] != 0x0 && (adminRegister[msg.sender] || msg.sender == this.owner)){
			codeRegister[_id].definition = definition;
			codeRegister[_id].dateModified = block.timestamp;
			editCodeLog();
		}
	}

	function getCode(uint _id) returns (categoryCode code){ 
		//anyone can access the codes
		return codeRegister[_id];
	}

	// --- ADMIN  ---

	function makeAdmin(address newAdmin){
		//trustnet creator and other admins can create admins
		if(adminRegister[msg.sender] || msg.sender == this.owner){
			adminRegister[newAdmin] = true;
			makeAdminLog();	
		}
	}

	function revokeAdmin(address revokedAdmin){
		//only the trustnet creator can revoke admin rights
		if(msg.sender == this.owner){
			adminRegister[revokedAdmin] = false;
			revokeAdminLog();
		}
	}

	function isAdmin(address queryAddr) returns (bool res){
		if(adminRegister[queryAddr] == 0x0){
			return false;
		} else {
			return adminRegister[queryAddr];
		}

	}
}