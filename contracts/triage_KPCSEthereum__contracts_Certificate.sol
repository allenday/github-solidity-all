import {User} from "./User.sol";
import {Participant} from "./Participant.sol";
import {ParticipantAuthority} from "./ParticipantAuthority.sol";
import {UserState} from "./UserState.sol";

contract Certificate {

    address public constant owner = msg.sender;
    address public kpcs;

    enum State {
        /*
        Created: certificate has been created, but awaiting addition of parsels
        Pending: parsels added, awaiting signatures from issuer and either importer or exporter
        Issued: all signatures received, certificate is valid.
        Completed: shipment validated upon border crossing
        Expired: shipment has expired without receiving a 'completed' Event
        */
        Created, Pending, Issued, Completed, Expired
    }
    State private state = State.Created;

    struct Dates {
        //date the certificate is created + requested
        uint created;

        //date the certificate is signed by all parties and is officially issued
        uint issued;

        //date the shipment is certified by the importing authority
        uint completed;

        //default expiration date of the certificate, exercised only if shipment never verified by importing authority
        uint expired;
    }
    Dates public dates = Dates(now, 0, 0, 0);

    //Participants in the KP: member countries of source and destination
    struct Participants {
        address[] origins; //the declared origin of the goods
        address source; //the country we are exporting from
        address destination; //the country we are importing to
    }
    Participants private participants;

    //the parties to the transaction: importer and exporter
    struct Parties {
        address exporter;
        address importer;
    }
    Parties public parties;

    struct Signature {
        uint date;
        address owner;
    }

    struct Signatures {
        Signature exporter;
        Signature importer;
        Signature importerOnReceipt;
        Signature exporterAuthority;
        Signature importerAuthority;
        Signature importerAuthorityOnReceipt;
    }
    Signatures private signatures;

    struct Parsel {
        uint carats;
        uint value;
        address[] origins;
    }
    Parsel[] public parsels;

    //expire this certificate 30 days in the future
    uint private constant expirationDateFromNow = now + (60 * 60 * 24 * 30);

    //when the certificate is created by the exporting party
    event Created(address indexed certificate);

    //when the parsels have been added, and the certificate is awaiting signing by parties and authorities
    event Pending(address indexed certificate,
        address exporter,
        address importer,
        address participantSource,
        address participantDestination);

    //when all required parties and authorities have signed the certificate
    event Issued(address indexed certificate);

    //when a certificate has been signed by a party of authority's agent
    event Signed(address from, string name);

    event Expired(address indexed certificate);

    //when a certificate completes transit of an international border,
    //and is marked as received by the improting authority
    event Complete(address from, string name);

    /*
    Certificates should be created by the exporter: the party in possession of the goods.
    params:
    - importer - importing Party
    - exporter - exporting Party
    - participantOrigin - KPCS Participant (member country) the goods were sourced _from_
      ... likely the country of geological origin
    - participantSource - KPCS Participant (member country) the goods are being sent from
    - participantDestination - KPCS Participant (member country) the goods are being sent to
    */
    function Certificate(address _kpcs,
        address _exporter,
        address _importer,
        address _participantSource,
        address _participantDestination) {
            kpcs = _kpcs;
            parties = Parties(_exporter, _importer);
            if(User(parties.exporter).getState() == UserState.Accepted()) {
                participants = Participants(new address[](0x0), _participantSource, _participantDestination);
                signatures = Signatures(
                    Signature(now, _exporter),
                    Signature(0,0x0),
                    Signature(0,0x0),
                    Signature(0,0x0),
                    Signature(0,0x0),
                    Signature(0,0x0));
                dates = Dates(now, 0, 0, expirationDateFromNow);
                Created(this);
            }
    }

    function kill() {
        if (msg.sender == owner && state == State.Pending) {
            suicide(owner);
        }
    }

    function getNumberOfParticipantsOrigins() constant returns (uint) {
        return participants.origins.length;
    }

    function getParticipantOriginWithIndex(uint index) constant returns (address) {
        return participants.origins[index];
    }

    function getParticipantSource() constant returns (address) {
        return participants.source;
    }

    function getParticipantDestination() constant returns (address) {
        return participants.destination;
    }

    function getParticipants() constant returns (address[]) {
        address[] memory allParticipants = new address[](participants.origins.length + 2);
        allParticipants[0] = (participants.source);
        allParticipants[1] = participants.destination;
        uint origins = participants.origins.length;
        for(uint i = 0; i<origins; i++) {
            allParticipants[i + 2] = participants.origins[i];
        }
        return allParticipants;
    }

    function addParsel(uint carats, uint value, address[] origins) {
        if(msg.sender != owner || state != State.Created) {
            return;
        }
        parsels.push(Parsel(carats, value, origins));
        for(uint index = 0; index < origins.length; index++) {
            participants.origins.push(origins[index]);
        }
    }

    function completedAddingParsels() {
        if(msg.sender != owner || state != State.Created) {
            return;
        }
        state = State.Pending;
        Pending(this, parties.exporter, parties.importer, participants.source, participants.destination);
    }

    function getImportingParty() returns (address) {
        return User(parties.importer);
    }

    function getExportingParty() returns (address) {
        return User(parties.exporter);
    }    

    function getSignatures() returns (uint[4]) {
        return [signatures.exporter.date,
            signatures.importer.date, 
            signatures.exporterAuthority.date,
            signatures.importerAuthority.date
        ];
    }

    function canSign() returns (bool) {
        if(state != State.Pending) {
            return false;
        }

        if(ParticipantAuthority(Participant(participants.source).getExportingAuthority()).isSenderRegisteredAgent(msg.sender)) {
            if(signatures.exporterAuthority.date > 0) {
                return false;
            }
            if(Participant(participants.source).getState() != UserState.Accepted()) {
                return false;
            }
            return true;
        } else if(ParticipantAuthority(Participant(participants.destination).getImportingAuthority()).isSenderRegisteredAgent(msg.sender)) {
            if(signatures.importerAuthority.date > 0) {
                return false;
            }
            if(Participant(participants.destination).getState() != UserState.Accepted()) {
                return false;
            }
            return true;
        } else if(msg.sender == User(parties.importer).getOwner()) {
            if(signatures.importer.date > 0 || User(parties.importer).getState() != UserState.Accepted()) {
                return false;
            }
            return true;
        }
        return false;
    }

    function sign() {
        if(state != State.Pending) {
            return;
        }

        if(ParticipantAuthority(Participant(participants.source).getExportingAuthority()).isSenderRegisteredAgent(msg.sender)) {
            if(signatures.exporterAuthority.date > 0) {
                return;
            }
            if(Participant(participants.source).getState() != UserState.Accepted()) {
                return;
            }
            Signed(msg.sender, "Exporting Authority");
            signatures.exporterAuthority = Signature(now, msg.sender);
        } else if(ParticipantAuthority(Participant(participants.destination).getImportingAuthority()).isSenderRegisteredAgent(msg.sender)) {
            if(signatures.importerAuthority.date > 0) {
                return;
            }
            if(Participant(participants.destination).getState() != UserState.Accepted()) {
                return;
            }
            Signed(msg.sender, "Importing Authority");
            signatures.importerAuthority = Signature(now, msg.sender);
        } else if(msg.sender == User(parties.importer).getOwner()) {
            if(signatures.importer.date > 0 || User(parties.importer).getState() != UserState.Accepted()) {
                return;
            }
            Signed(msg.sender, "Importing Party");
            signatures.importer = Signature(now, msg.sender);
        } else {
            return;
        }

        if(hasRequiredSignaturesToValidate()) {
            state = State.Issued;
            dates.issued = now;
            Issued(this);
        }
    }

    function markAsReceived() {
        if(ParticipantAuthority(Participant(participants.destination).getImportingAuthority()).isSenderRegisteredAgent(msg.sender)) {
            if(signatures.importerAuthorityOnReceipt.date > 0) {
                return;
            }
            dates.completed = now;
            signatures.importerAuthorityOnReceipt = Signature(now, msg.sender);
            state = State.Completed;
            Complete(msg.sender, "Importing Authority - On Receipt");
        } else if(msg.sender == User(parties.importer).getOwner()) {
            if(signatures.importerOnReceipt.date > 0) {
                return;
            }
            signatures.importerOnReceipt = Signature(now, msg.sender);
            state = State.Completed;
            Complete(msg.sender, "Importing Party - On Receipt");
        }
    }

    function hasRequiredSignaturesToValidate() returns (bool isComplete) {
        return (signatures.importerAuthority.date > 0 && signatures.exporterAuthority.date > 0 && signatures.importer.date > 0 && signatures.exporter.date > 0);
    }

    function expireIfNecessary() {
        if(now >= dates.expired && state == State.Issued) {
            state = State.Expired;
        }
        Expired(this);
    }

    function isExpired() returns (bool) {
        return (state == State.Expired);
    }

    function isComplete() returns (bool) {
        return (state == State.Completed);
    }

    function isValid() returns (bool) {
        return (state == State.Issued && now < dates.expired);
    }
}
