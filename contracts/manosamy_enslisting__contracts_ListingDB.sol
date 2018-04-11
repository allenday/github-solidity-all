pragma solidity ^0.4.11;

contract ListingDB {

    enum BidStatus {blank, bid, accepted, declined, escrowed}

	struct Listing {
        address listingAgent;
        uint listPrice;
        uint64 latestBidId;
        uint64 latestEscrowId;
        string name;
        string email;
    }

    struct Bid {
        address bidder;
        uint bidAmount;
        string name;
        string email;
        uint escrowId;
    }
    
    struct Admin {
        address owner;
        address registry;
        address listingService;
        address escrowService;
    }
    
    struct Index {
        uint64 nextListingId;
        uint64 nextBidId;    
    }
    
	mapping(uint64 => Listing) public listings;
	mapping(uint64 => BidStatus) public bidStatus;
	mapping(uint64 => Bid) public bids;

    Admin public admin;
    Index public index;

  	modifier onlyByRegistry() {
  	    require(msg.sender == address(admin.registry));
        _;
  	}
  	
  	modifier onlyByOwner() {
  	    require(msg.sender == address(admin.owner));
        _;
  	}
  	
    modifier onlyByListingService() {
  	    require(msg.sender == address(admin.listingService));
        _;
  	}
  	
  	modifier onlyByEscrowService() {
  	    require(msg.sender == address(admin.escrowService));
        _;
  	}

    /// Create a new Listing.
    function ListingDB(uint64 _nextListingId, uint64 _nextBidId, address _registry) {
        admin = Admin({owner: msg.sender, registry: _registry, listingService: address(0x0), escrowService: address(0x0)});
        index = Index({nextListingId: _nextListingId, nextBidId: _nextBidId});
    }
    
    function namehash(string name) constant returns(bytes32) {
    	return sha3(0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae, sha3(name));
    }
    
    function updateService(address _listingService, address _escrowService) onlyByRegistry {
        admin.listingService = _listingService;
        admin.escrowService = _escrowService;
    }
    
    function service() constant returns (address) {
        return admin.listingService;
    }
    
    function index() constant returns (uint64, uint64) {
        return (index.nextListingId, index.nextBidId);
    }
    
    function listings(uint64 listingId) constant returns (address listingAgent, uint listPrice, bytes32 labelHash) {
        var l = listings[listingId];
        return (l.listingAgent, l.listPrice, sha3(l.name));
    }
    
    function withdraw(uint _amount) onlyByOwner {
        admin.owner.transfer(_amount);
    }
    
    function addListing(string _name, string _email, uint _listPrice, address _listingAgent) onlyByListingService returns(uint64 listingId) {
        //All rules will be enforced by Controller
        listingId = index.nextListingId++;
        listings[listingId] = Listing({name: _name, email:_email, listPrice: _listPrice, listingAgent: _listingAgent, latestBidId: 0, latestEscrowId: 0});
        return listingId;
    } 
    
    function getBidInfo(uint64 bidId) constant returns(bytes32 labelHash, BidStatus status, address bidder, uint bidAmount) {
        var bid = bids[bidId];
        return (sha3(bid.name), bidStatus[bidId], bid.bidder, bid.bidAmount);
    }
    
    function setBidStatus(uint64 bidId, BidStatus status) onlyByListingService {
        bidStatus[bidId] = status;
    }

    function addBid(string _name,string _email, uint _bidAmount, address _bidder) onlyByListingService returns (uint64 bidId){
        //All rules will be enforced by Controller
        bidId = index.nextBidId++;
        bids[bidId] = Bid({bidder: _bidder,email:_email, name:_name, bidAmount: _bidAmount, escrowId: 0});
        bidStatus[bidId] = BidStatus.bid;
        return bidId;
    } 

    function recordEscrowOnBid(uint64 _optionalBidId, uint64 _escrowId) onlyByEscrowService {
        //All rules will be enforced by Service
        bidStatus[_optionalBidId] = BidStatus.escrowed;
        bids[_optionalBidId].escrowId = _escrowId;
    } 
    
    function () payable {
    }
}