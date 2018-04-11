pragma solidity ^0.4.6;
contract VersionedAgreementControll {

    // Store the owner address
    address public owner;
    
    // Constructor
    function VersionedAgreementControll() {
        owner = msg.sender;
    }  

    /**
        Stores the subscriber information
    */
    struct SubscriberData {
        address member;
        string email;
        string otherIdentity;
    }    

    // Signature data
    struct Signature {
        address signer;
        uint64 signTime;
        string message;
        uint versionId;
    }

    /**
        Controlls every agreement version, and its signers
    */
    struct Version {
        uint id;
        uint64 createTime;
        address owner;
        string tag;
        bytes contractData;
        address[] signedBy;
    }    
    
    // List of default subscribers to this contract
    address[] subscribers;
    // List of versions for this contract
    Version[] versions;  
    // Store which version was signed by who
    Signature[] signatures;
    // store subscribers data
    SubscriberData[] subscribersInfos;

    // Event fired uppon creating an new version
    event CreateNewVersionEvent(uint commitId, string tag);    

    // Function modifier that grants that the sender is the owner
    modifier isOwner {
        if (msg.sender == owner) _;
    }

    // Function modifier that grants that the sender is a subscriber
    modifier isSubscriber {
        for (uint i = 0; i < subscribers.length; i++) {
            if (msg.sender == subscribers[i]) _;
        }
    }

    // Set a new owner to this contract
    function SetOwner(address newOwner) isOwner {
        owner = newOwner;
    }

    // Adds a subscriber to the default subscribers list
    function AddSubscriber(address member, string email, string id) isOwner {        
        subscribers[subscribers.length++] = member;
        subscribersInfos.push(SubscriberData(member, email, id));
    }

    function GetSubscribers() constant returns (address[]) {
        return subscribers;
    }

    function GetWhoSignedAVersion(string tag) constant returns (address[]) {
        var i = findTag(tag);        
        return versions[i].signedBy;
    }

    // Finds a subscriber index by its address
    function findSubscriberIndex(address member) private returns(int) {
        for (uint i = 0; i < subscribers.length; i++) {
                if (member == subscribers[i]) {
                return int(i);
            }
        }
        return -1;
    }

    // Removes a subscriber from the default subscriber list
    function RemoveSubscriber(address member) isOwner {
        int i = findSubscriberIndex(member);
        if (i != -1) delete subscribers[uint(i)];    
    }

    function GetVersions() isSubscriber isOwner returns(uint[] ids) {
        for(uint i = 0; i < versions.length; i++) {
            ids[i] = versions[i].id;
        }
    } 

    // transforms into 
    function uintToBytes(uint v) private constant returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        }
        else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }
    
    // now byte to string
    function bytes32ToString(bytes32 x) private constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    // Stores a contract version and signs it by the version creator
    function CreateVersion(bytes blob, string tag) isSubscriber returns (int) {

        int memberIndex = findSubscriberIndex(msg.sender);
        if (memberIndex == -1) return -1;

        address member = subscribers[uint(memberIndex)];

        int tagix = findTag(tag);
        if (tagix != -1) return -1; // "the choosen tag already exists";
        
        uint64 nowInt = uint64(now);
        
        //versions.push(Version(commitId, nowInt, member.member, tag, blob));
        uint commitId = versions.length++;
        versions[commitId].id = commitId;
        versions[commitId].createTime = nowInt;
        versions[commitId].owner = member;
        versions[commitId].tag = tag;
        versions[commitId].contractData = blob;
        
        //signatures.push(Signature(member, nowInt, tag, commitId));
        SignVersion(tag, "version signing");

        //uint six = signatures.length++;
        //signatures[six].signer = member;
        //signatures[six].signTime = nowInt;
        //signatures[six].message = tag;
        //signatures[six].versionId = commitId;
        
        CreateNewVersionEvent(commitId, tag);

        return int(commitId);
    }

    // Rename a version to another name
    function Rename(string oldTag, string tag) {
        int i = findTag(oldTag);
        if (i == -1) return;

        versions[uint(i)].tag = tag;    
    }

    // finds a contract by its tag
    function findTag(string tag) private returns (int) {
        bytes32 hash = sha3(tag);
        for (uint i = 0; i < versions.length; i++) {
            // Not possible to compare strings directly yet.
            if (sha3(versions[i].tag) == hash) {
                return int(i);
            }
        }
        return -1;
    }

    // reads the content of the contract
    function ReadContent(string tag) constant returns (bytes) {
        int i = findTag(tag);
        if (i >= 0) {
            return versions[uint(i)].contractData;
        }
    }

    // find a signature on a version
    function findSignature(Version version) private returns (int) {
        for (uint i = 0; i < signatures.length; i++) {
            Signature currsig = signatures[i];
            if (currsig.signer == msg.sender && currsig.versionId == version.id)
                return int(i);
        }
        return -1;
    }

    // This function will be called from an external contract just to sign
    function SignVersion(string tag, string message) returns (string) {
        int subsid = findSubscriberIndex(msg.sender);
        if (subsid == -1) return "the provided member is not a subscriber";

        uint usubix = uint(subsid);

        int versionIndex = findTag(tag);
        if (versionIndex < 0) return "the provided version does not exists";
        
        uint uverix = uint(versionIndex);
        Version currver = versions[uverix];
        
        int sigix = findSignature(currver);
        if (sigix != -1) return "the member already signed this version";                

        Signatuer sig = Signature(subscribers[usubix], uint64(now), message, currver.id);
        signatures.push(sig);
        currver.signedBy.push(msg.sender);

        return "signature collected with success";
    }

    // sign current version of the contract
    function SignCurrentVersion(string message) returns (string) {
        if (versions.length == 0)
            return "No version found. Use CreateVersion with a new contract";
            
        return SignVersion(versions[versions.length -1].tag, message);
    }
}