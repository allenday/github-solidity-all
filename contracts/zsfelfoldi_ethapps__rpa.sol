contract RPAcontract {

/*
Ethereum contract for handling Recursive Promises of Availability (RPAs)
work-in-progress version
 by Zsolt Felfoldi <zsfelfoldi@gmail.com>
 parts taken from solidity contract implementation by Daniel A. Nagy <daniel@ethdev.com>
*/


uint constant GRACE = 50; // grace period for lost information in blocks
uint constant REWARD_FRACTION = 10; // this fraction of a deposit is paid as reward

bytes32 constant tdRPA = "RPA";

struct RPAissuer {
    uint deposit;    // amount deposited by this member
    uint expiry;     // expiration time of the deposit
    bytes32 missing; // object requested from issuer, based on signed RPA or referenced by another object requested from this issuer
    uint deadline;   // block number before which object must be presented
    address reporter; // receipt reported by this address
}

mapping (address => RPAissuer) issuers;


mapping (bytes32 => uint) objPresented;				// object data presented in this block
mapping (bytes32 => mapping (bytes32 => uint)) objRef;		// object reference proven in this block
mapping (address => mapping (uint => mapping (bytes32 => address))) objRequested;
// object request based on receipt (signer, expiry, objHash) posted by stored key


bytes32 constant rpaBinary = "Binary";
bytes32 constant rpaBlockHeader = "BlockHeader";
bytes32 constant rpaPrevBlockHeader = "PrevBlockHeader";
bytes5 constant rpaTrie = "Trie.";
bytes32 constant rpaAccount = "Account";
bytes32 constant rpaTxReceipt = "TxReceipt";

bytes32 constant rpaState = "Trie.Account";
bytes32 constant rpaStorage = "Trie.Binary";
bytes32 constant rpaTransactions = "Trie.Binary";
bytes32 constant rpaReceipts = "Trie.TxReceipt";

function addRef(bytes32 parentObj, bytes32 childObj) internal {
    if (objRef[parentObj][childObj] == 0) {
        objRef[parentObj][childObj] = block.number;
    }
}

function presentObject(bytes data, bytes32 typeID) external {
    bytes32 dataHash = sha3(data);
    bytes32 objHash = sha3(dataHash, typeID);
    objPresented[objHash] = block.number;

    if (typeID == rpaBlockHeader) {

// process block header found in data
// extract parentHash, transactionsRoot, receiptsRoot

        addRef(parentHash, rpaPrevBlockHeader);
        addRef(transactionsRoot Trie(Transaction)
        addRef(receiptsRoot Trie(TxReceipt)
        return;
    }

    if (typeID == rpaPrevBlockHeader) {
// process data, add references
        return;
    }

    if (typeID == rpaAccount) {
// process data, add references
        return;
    }

    if (typeID == rpaTxReceipt) {
// process data, add references
        return;
    }

    if (bytes5(typeID) == rpaTrie) {
// process data, add references
        return;
    }
}


function newRequest(address signer, uint expiry, bytes32 objHash) internal {
    objRequested[signer][expiry][objHash] = msg.sender;
    if(!isClean(signer) || !expiresAfter(signer, now) || (objPresented[objHash] != 0)) return;
    RPAissuer b = issuers[signer];
    b.missing = objHash;
    b.deadline = block.number + GRACE;
    b.reporter = msg.sender;
    Report(signer);
}

function requestObjectRoot(bytes32 objHash, uint expiry,
    uint8 sig_v, bytes32 sig_r, bytes32 sig_s) {
    if(expiry < now) return;
    bytes32 recptHash = sha3(tdRPA, objHash, expiry);
    address signer = ecrecover(recptHash, sig_v, sig_r, sig_s);
    newRequest(signer, expiry, objHash);
}

function transitivePath(bytes32 parentObj, bytes32 childObj, bytes32 grandChildObj) {
    if ((objRef[parentObj][childObj] != 0) && (objRef[childObj][grandChildObj] != 0) && (objRef[parentObj][grandChildObj] == 0)) {
        objRef[parentObj][grandChildObj] = block.number;
    }
}

function propagateRequest(address signer, uint expiry, bytes32 parentObj, bytes32 childObj) {
    if ((objRef[parentObj][childObj] != 0) && (objRequested[signer][expiry][parentObj] != 0) && (objRequested[signer][expiry][childObj] == 0)) {
        newRequest(signer, expiry, childObj);
    }
}
  
function max(uint a, uint b) private returns (uint c) {
    if(a >= b) return a;
    return b;
}

function signup(uint time) {
    RPAissuer b = issuers[tx.origin];
    if(isClean(msg.sender) && now + time > now) {
        b.expiry = max(b.expiry, now + time);
    }
    b.deposit += msg.value;
}

function withdraw() {
    RPAissuer b = issuers[tx.origin];
    if(now > b.expiry && isClean(msg.sender)) {
	    msg.sender.send(b.deposit);
	    b.deposit = 0;
    }
}

function balance(address addr) returns (uint d) {
    RPAissuer b = issuers[addr];
    return b.deposit;
}

function isClean(address addr) returns (bool s) {
    RPAissuer b = issuers[addr];
    if(b.missing != 0 && objPresented[b.missing] != 0) b.missing = 0;
    return b.missing == 0; // nothing they signed is missing
}

event Report(address suspect);

function whatIsMissing() returns (bytes32 h) {
    bytes32 missing = issuers[tx.origin].missing;
    if(objPresented[missing] != 0) missing = 0;
    return missing;
}

  
function isGuilty(address addr) returns (bool g){
    if(isClean(addr)) return false;
    RPAissuer b = issuers[addr];
    return b.deadline < block.number;
}

function claimReporterReward(address addr) {
    if(!isGuilty(addr)) return;
    RPAissuer b = issuers[addr];
    msg.sender.send(b.deposit / REWARD_FRACTION); // reporter rewarded
    delete issuers[addr]; // rest of deposit burnt
}

function expiresAfter(address addr, uint time) returns (bool s) {
    RPAissuer b = issuers[addr];
    return b.expiry > time;
}

}
