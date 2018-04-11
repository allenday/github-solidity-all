contract localsUser {

	address owner;
	mapping(address => string) public users;

	event userAdded(address who, string hash);

	function localsUser(){
	    owner = msg.sender;
	}

	function setProfileHash(string _hash) {
		users[msg.sender] = _hash;
		userAdded(msg.sender, _hash);
	}

	function getProfileHash(address useraddress) returns (string userhash) {
		return users[useraddress];
	}

  function changeOwner(address newowner){
    if(msg.sender!=owner) throw;
    owner = newowner;
  }

	function kill() { if (msg.sender == owner) suicide(owner); }
}
