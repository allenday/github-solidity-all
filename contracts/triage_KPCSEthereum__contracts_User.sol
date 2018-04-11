import {UserType} from "./UserType.sol";

contract User {
	enum State {
		Applied, Accepted, Rejected, Suspended
	}
	State public state;

	event UserStateChanged(address user, State state, address administrator);

    address internal owner;
    address internal administrator;
    string internal name;
    uint public dateCreated = now;

	function User(string _name, address _administrator) {
		state = State.Applied;
		name = _name;
		owner = msg.sender;
		administrator = _administrator;
		UserStateChanged(this, state, administrator);
	}

	function getOwner() public returns (address) {
		return owner;
	}

	function setState(uint _state) returns (bool) {
		//user cannot change their own status, can only be done by the issuing administrator
		if(msg.sender != administrator) {
			return false;
		}
		state = State(_state);
		return true;
	}

	function getAdministrator() returns (address) {
		return administrator;
	}

	function getNameHash() returns (bytes32) {
		return sha3(name);
	}

	function getName() returns (string) {
		return name;
	}

	function getType() returns (int) {
		throw;
	}

	function getState() returns (uint) {
		return uint(state);
	}

	function accept() {
		if(msg.sender != User(administrator).getOwner()) {
			return;
		}
		state = State.Accepted;
	}

	function reject() {
		if(msg.sender != User(administrator).getOwner()) {
			return;
		}
		state = State.Rejected;
	}

	function suspend() {
		if(msg.sender != User(administrator).getOwner()) {
			return;
		}
		state = State.Suspended;
	}

	function kill() {
		if (msg.sender == owner) suicide(owner);
	}
}
