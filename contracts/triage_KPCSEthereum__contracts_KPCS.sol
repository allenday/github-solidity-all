import {User} from "./User.sol";
import {Certificate} from "./Certificate.sol";

contract KPCS {
	uint private constant UserStateAccepted = 1;

	address private owner;

	address public administrator;

	//all certificates
	mapping(address => address) public certificates;

	//member countries
	mapping(bytes32 => address) public participants;

	event ParticipantRegistered(address indexed participant, uint date);

	//CertificateValidated: when an issued (has all required signatures) certificate
	//has been presented to the KPCS instance and added to the list of certificates
	event CertificateValidated(address indexed certificate, uint date);

	function KPCS(address _administrator) {
		administrator = _administrator;
		owner = msg.sender;
	}

	function kill() {
		if (msg.sender == owner) suicide(owner);
	}

	function isCertificateRegisteredAndValid(address certificate) returns (bool) {
		return (Certificate(certificate).isValid() && certificates[certificate] != 0x0);
	}

	function registerCertificate(address _certificate) {
		Certificate certificate = Certificate(_certificate);
		//certificate already verifies state of the participants
		if(certificate.isValid()) {

			//check that all participants have registered with this instance
			User participantSource = User(certificate.getParticipantSource());
			if(!participantCanParticipate(participantSource)) {
				return;
			}

			User participantDestination = User(certificate.getParticipantDestination());
			if(!participantCanParticipate(participantDestination)) {
				return;
			}	

			uint numberOfParticipantsOrigins = certificate.getNumberOfParticipantsOrigins();
			for(uint i = 0; i < numberOfParticipantsOrigins; i++) {
				User participant = User(certificate.getParticipantOriginWithIndex(i));
				if(!participantCanParticipate(participant)) {
					return;
				}
			}

			certificates[_certificate] = certificate;
			CertificateValidated(_certificate, now);
			return;
		}
		throw;
	}

	function registerParticipant(address _participant) {
		bytes32 name = User(_participant).getNameHash();
		if(msg.sender != owner || participants[name] != 0x0) {
			return;
		}

		participants[name] = _participant;
		ParticipantRegistered(_participant, now);
	}

	function participantCanParticipate(address _participant) returns (bool) {
		bytes32 name = User(_participant).getNameHash();
		return (participants[name] == _participant);
	}
}
