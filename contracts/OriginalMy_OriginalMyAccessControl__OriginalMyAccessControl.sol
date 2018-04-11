contract OriginalMyAccessControl {
  	address public owner;
	mapping(address => bool)  superUser;
	mapping(address => bool)  manager;
	mapping(address => bool)  user;
	
	
	event SuperUser(address userAddress, bool enabled);
	event Manager(address userAddress, bool enabled);
	event User(address userAddress, bool enabled);
	
	
	function OriginalMyAccessControl() {
		owner = msg.sender;
		superUser[msg.sender] = true;
	}
	
	modifier Owner {
        	if (msg.sender != owner) throw;
	}

	
	function transferOwnership(address newOwner) Owner{
		owner = newOwner;
	}
	
	
	/* Enable superuser mapping */
	function enableSuperUser(address target, bool enable) {
		if (!superUser[msg.sender] && msg.sender != owner) throw;
		superUser[target] = enable;
		SuperUser(target, enable);
    	}

	
	/* Enable manager mapping */
	function enableManager(address target, bool enable) {
		if (!superUser[msg.sender] && !manager[msg.sender] && msg.sender != owner) throw;
		manager[target] = enable;
		Manager(target, enable);
    	}

	/* Enable user mapping */
	function enableUser(address target, bool enable) {
		if (!superUser[msg.sender] && !manager[msg.sender] && msg.sender != owner) throw;
		user[target] = enable;
		User(target, enable);
	}

	
	/* Check Super User Access */
	function isSuperUser(address target) {
		if (!superUser[target] && target != owner) throw;
	}
	
	/* Check Manager Access */
	function isManager(address target) {
		if (!superUser[target] && !manager[target] && target != owner) throw;
	}
	
	/* Check User Access */	
	function isUser(address target) {
		if (!superUser[target] && !manager[target] && !user[target] && target != owner) throw;
	}
	
	function(){
		throw;
	}

}
