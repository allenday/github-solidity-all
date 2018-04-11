contract Identity {

	event UserRegistered(string username, address addr);
	event OwnerChanged(string username, address oldOwner, address newOwner);

	mapping (string => address) identityMapping;

	address owner;

	function Identity() {
		owner = msg.sender;
	}

	function register(string username) returns (bool) {
		if (identityMapping[username] == 0) {
			identityMapping[username] = msg.sender;
			UserRegistered(username, msg.sender);
			return true;
		} else {
			return false;
		}
	}

	function changeOwner(string username, address addr) returns (bool) {
		if (identityMapping[username] == msg.sender) {
			OwnerChanged(username, identityMapping[username], addr);
			identityMapping[username] = addr;
			return true;
		} else {
			return false;
		}
	}

	function getCurrentOwner(string username) constant returns (address) {
		return identityMapping[username];
	}

	function kill() {
		if (owner == msg.sender) {
			selfdestruct(owner);
		}
	}

	function() {
		owner.send(this.balance);
	}

}
