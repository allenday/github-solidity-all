import {Administrator} from "./Administrator.sol";
import {UserType} from "./UserType.sol";

contract ParticipantAgent is Administrator("name", 0x0) {
	/*
		ParticipantAgents are entities delegated by Participants
		(e.g. the Minister of Mines and Mining) the power to
		issue certificates.

		These individuals can act on behalf of the Particiapnt to:
		1. sign certificates
		2. managed Party entities

	*/

	function ParticipantAgent(string _name, address _administrator) {
		name = _name;
		administrator = _administrator;
	}

	function getType() returns (int) {
		return UserType.ParticipantAgent();
	}
}
