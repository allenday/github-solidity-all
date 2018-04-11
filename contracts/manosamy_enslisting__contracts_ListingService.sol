pragma solidity ^0.4.11;

contract AbstractENSRegistrar {
    function entries(bytes32 _hash) constant returns (uint, address, uint, uint, uint);
    function transfer(bytes32 _hash, address newOwner);
}
 
contract AbstractDeed {
    address public owner;
}

contract AbstractListingDB {
    enum BidStatus {blank, bid, accepted, declined, escrowed}
    function addListing(string _name, string _email, uint _listPrice, address _listingAgent) returns(uint64 listingId);
    function getBidInfo(uint64 bidId) constant returns(bytes32 labelHash, BidStatus status, address bidder, uint bidAmount);
    function listings(uint64 listingId) constant returns (address listingAgent, uint listPrice, bytes32 labelHash);
    function setBidStatus(uint64 _bidId, BidStatus _status);
    function addBid(string _name,string _email, uint _bidAmount, address _bidder) returns (uint64 _bidId);
}

contract ListingService {

    struct Admin {
        //0x006090a6e47849629b7245dfa1ca21d94cd15878ef for main-net
        address ensRegistrarAddr; 
        address registry;
        AbstractListingDB listingDB;
    }
      	
    modifier onlyByRegistry() {
  	    require(msg.sender == address(admin.registry));
        _;
  	}

    Admin public admin;
    bool abandoned;
    
    function namehash(string name) constant returns(bytes32) {
    	return sha3(0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae, sha3(name));
    }
    
    function abandon() onlyByRegistry {
  	    abandoned = true;
  	}
  	
  	
  	
  	modifier onlyWhenActive() {
    	require(abandoned == false);
        _;
  	}

    modifier whenCallerStillOwnsTheDomain(string name) {
        var (,_deedAddr,,,) = AbstractENSRegistrar(admin.ensRegistrarAddr).entries(sha3(name));
        require(msg.sender == AbstractDeed(_deedAddr).owner());
        _;
  	}

    /// Create a new Listing.
    function ListingService(address registrar, address _registry, AbstractListingDB _listingDB) {
        admin = Admin({ensRegistrarAddr: registrar, registry: _registry, listingDB:_listingDB});
        abandoned = false;
    }

    function payTip() payable {
        admin.listingDB.transfer(msg.value);
    }
    
    function addListing(string name,string email, uint listPrice) payable whenCallerStillOwnsTheDomain(name) onlyWhenActive {
        //relisting is allowed, as a way to update.
        uint64 listingId = admin.listingDB.addListing(name,email, listPrice, msg.sender);
        ListingAdded(namehash(name), name, email, listPrice, listingId);
        if(msg.value >0)
            payTip();
    } 

    function bid(string name,string email, uint bidAmount) payable onlyWhenActive {
	    //bidding on an unlisted ens is also allowed, soliciting
	    uint64 bidId = admin.listingDB.addBid(name, email, bidAmount, msg.sender);
	    BidPosted(namehash(name), name, email, bidAmount, bidId);
	    if(msg.value >0)
	        payTip();
    }
    
	function acceptBid(string name, uint64 bidId) payable whenCallerStillOwnsTheDomain(name) {
        bytes32 labelHash = sha3(name);
        var (labelHashOnBid, , , ) = admin.listingDB.getBidInfo(bidId);
        if(labelHashOnBid == labelHash) {
            admin.listingDB.setBidStatus(bidId, AbstractListingDB.BidStatus.accepted);
	        BidAccepted(namehash(name), name, bidId);
        } else
	        throw;
	    if(msg.value >0)
            payTip();   
    }
    
    function declineBid(string name, uint64 bidId) payable whenCallerStillOwnsTheDomain(name) {
        bytes32 labelHash = sha3(name);
        var (labelHashOnBid, , , ) = admin.listingDB.getBidInfo(bidId);
        if(labelHashOnBid == labelHash) {
            admin.listingDB.setBidStatus(bidId, AbstractListingDB.BidStatus.declined);
	        BidDeclined(namehash(name), name, bidId);
        } else
	        throw;
	    if(msg.value >0)
            payTip();    
    }

     // Events allow light clients to react on changes efficiently.
    event ListingAdded(bytes32 indexed namehash, string name,string email, uint listPrice, uint64 listingId);
    event BidPosted(bytes32 indexed namehash, string name,string email, uint bidAmount, uint64 bidId);
    event BidAccepted(bytes32 indexed namehash, string name, uint64 bidId);
    event BidDeclined(bytes32 indexed namehash, string name, uint64 bidId);

 
}