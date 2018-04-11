/// @title BITNATION citizens map

pragma solidity ^0.4.0;

contract BitnationMap {
	// Hold all the rigistered citizens
	address[] public citizens;
	// Associate a citizen and a location
	mapping(address => string) public register;

	function updateMe(string location) {
		// Register the caller, or change its location
		if (!isRegistered(msg.sender)) {
			citizens.push(msg.sender);
		}
		register[msg.sender] = location;
	}

	function getCitizenLocation(address citizen) returns (string) {
		return register[citizen];
	}

	function getNbCitizensLocation(string location) returns (uint) {
		uint nb = 0;
		for (uint i=0; i < citizens.length; ++i) {
			if (sha3(register[citizens[i]]) == sha3(location)) {
				nb++;
			}
		}
	}

	function isRegistered(address citizen) returns (bool) {
		for (uint i=0; i < citizens.length; ++i) {
			if (citizens[i] == citizen) {
				return true;
			}
		}
		return false;
	}
}

