/*
BlocktubeUser is an index of all the blocktube users linking 
their address to their profile info. Publishing your user profile
is optional.
*/
import "owned.sol";
contract blocktubeUser  is owned {

	
	mapping(address => string) public users;

	event userAdded(address who, string hash);

	function blocktubeUser(){
	}

	function setProfileHash(string _hash) {
		users[msg.sender] = _hash;
		userAdded(msg.sender, _hash);
	}

	function getProfileHash(address useraddress) returns (string userhash) {
		return users[useraddress];
	}

	function kill() onlyOwner { suicide(owner); }
}
