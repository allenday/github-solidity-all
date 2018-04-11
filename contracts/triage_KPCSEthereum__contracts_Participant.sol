import {Administrator} from "./Administrator.sol";
import {UserType, User} from "./User.sol";
import {ParticipantAuthority} from "./ParticipantAuthority.sol";

/*
	Participants are member countries that participate in the Kimberley Process.
	They delegate ParticipantAgents, which are entities (e.g. the Minister of Mines
	and Mining), which have the power to issue certificates
*/
contract Participant is Administrator("name", 0x0) {
	mapping(address => bool) public registeredAddresses;

	event ParticipantCreated(address participant, string name, address administrator);

	//KPCS Core Document - IV Each particpant should: (b) designate an Importing and an Exporting Authority(ies);
	struct Authorities {
		address importing;
		address exporting;
	}
	Authorities private authorities;

	event ImportingAuthorityAcceptedRegistered(address authority);
	event ExportingAuthorityAcceptedRegistered(address authority);

	function Participant(string _name, address _administrator) {
		name = _name;
		administrator = _administrator;
		ParticipantCreated(this, name, administrator);
		authorities = Authorities(0x0, 0x0);
	}

	function getType() returns (int) {
		return UserType.Participant();
	}

	function getImportingAuthority() returns (address) {
		return authorities.importing;
	}

	function getExportingAuthority() returns (address) {
		return authorities.exporting;
	}

	function isAcceptedImportingAuthority(address authority) returns (bool) {
		return authorities.importing == authority;
	}

	function isAcceptedExportingAuthority(address authority) returns (bool) {
		return authorities.exporting == authority;
	}

	function registerAsImportingAuthority(address authority) returns (bool) {
		if(msg.sender != owner || authorities.importing != 0x0) {
			return false;
		}
		authorities.importing = authority;
		ImportingAuthorityAcceptedRegistered(authority);
		return true;
	}

	function registerAsExportingAuthority(address authority) returns (bool) {
		if(msg.sender != owner || authorities.exporting != 0x0) {
			return false;
		}
		authorities.exporting = authority;
		ExportingAuthorityAcceptedRegistered(authority);
		return true;
	}
}
