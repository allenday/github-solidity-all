import {Administrator} from "./Administrator.sol";
import {UserType} from "./UserType.sol";
import {User} from "./User.sol";

/*
	ParticipantAuthorities are entities (e.g. The Minister of Mines and Mining),
	designated by a Participant (country) as having the power to issue certificates,
	which is a responsibility that they delegate to their agents acting on their behalf
	(e.g. an employee at the Minister of Mines and Mining).
*/

contract ParticipantAuthority is Administrator("name", 0x0) {

	mapping(address => bool) private agents;

	event ParticipantAgentRegistered(address agent);

	function ParticipantAuthority(string _name, address _administrator) {
		name = _name;
		administrator = _administrator;
	}

	function isSenderRegisteredAgent(address sender) returns (bool) {
		return agents[sender] == true;
	}

	function registerParticipantAgent(address agent) {
		if(msg.sender != owner || agents[address(User(agent).getOwner())] == true || User(agent).state() != State.Accepted) {
			return;
		}
		agents[address(User(agent).getOwner())] = true;
		ParticipantAgentRegistered(agent);
	}

	function getType() returns (int) {
		return UserType.ParticipantAuthority();
	}
}
