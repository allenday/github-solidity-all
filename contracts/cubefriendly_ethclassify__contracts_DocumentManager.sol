contract DocumentManager {
	
    mapping (uint => Document) documents;
    uint public nbDocuments;
    address public owner;

	enum Status {UNKNOWN,OPEN,DONE,DENIED}

    struct Document{
        address owner;
        string document;
        string name;
        uint nbRequests;
        string privateKey;
        mapping (uint => Request) requests;    
    }

	struct Request {
		address owner;
		Status status;
        string key;
	}

	function DocumentManager() {
        owner = msg.sender;
    }

    function newDocument(string hash, string name) {
        nbDocuments++;
        documents[nbDocuments].owner = msg.sender;
        documents[nbDocuments].document = hash;
        documents[nbDocuments].name = name;
        documents[nbDocuments].nbRequests = 0;
    }

    function grantAccess(uint documentId, uint requestId, string encryptedKey) {
        var document = documents[documentId];
        if(document.owner == msg.sender) {
            document.requests[requestId].status = Status.DONE;
            document.requests[requestId].key = encryptedKey;
        }
    }

    function denyAccess(uint documentId, uint requestId) {
        var document = documents[documentId];
        if(document.owner == msg.sender) {
            document.requests[requestId].status = Status.DENIED;
        }
    }

    function requestDocument(uint documentId, string publicKey) {
        var document = documents[documentId];
        document.nbRequests++;
    	var request = document.requests[document.nbRequests];
    	request.status = Status.OPEN;
    	request.owner = msg.sender;
        request.key = publicKey;
    }

    function getLastRequestId(uint documentId) returns (uint) {
        return documents[documentId].nbRequests;
    }

    function getOpenRequestPublicKey(uint documentId, uint requestId) returns (string) {
        var request = documents[documentId].requests[requestId];
        if(request.status == Status.OPEN) {
            return request.key;
        }
        return "";
    }

    function getRequestOwner(uint documentId, uint requestId) returns (address) {
        var document = documents[documentId];
        if(document.owner == msg.sender){
            return document.requests[requestId].owner;
        }
    }

    function getDocument(uint documentId) returns (string hash) {
            return documents[documentId].document;
    }

    function getDocumentName(uint documentId) returns (string name) {
        return documents[documentId].name;
    }

    function getEncryptedKeyFromRequest(uint documentId, uint requestId) returns (string) {
        var request = documents[documentId].requests[requestId];
        if(request.status == Status.DONE) {
            return request.key;
        }
        return '';
    }

    function getDocumentHash(uint documentId) returns (string) {
        return documents[documentId].document;
    }

    function getRequestStatus(uint documentId, uint requestId) returns (Status) {
        return documents[documentId].requests[requestId].status;
    }

}
