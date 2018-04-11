pragma solidity ^0.4.11;

contract AbstractListingDB {
    function updateService(address _listingService, address _escrowService);
}

contract AbstractService {
    function abandon();
}

contract ListingRegistry {
    
    struct Admin {
    	address owner;
        uint8 version;
        uint8 listingDBVersion;
        uint8 listingServiceVersion;
        uint8 escrowServiceVersion;
    	bool abandoned;
    }
    
	mapping(uint => address) public listingServices;
	mapping(uint => address) public listingDBs;
	mapping(uint => address) public escrowServices;
    Admin public admin;
	
	function ListingRegistry(uint8 _version, uint8 _listingDBVersion, uint8 _listingServiceVersion, uint8 _escrowServiceVersion) {
	    admin = Admin({owner:msg.sender, version:_version, listingDBVersion:_listingDBVersion, listingServiceVersion:_listingServiceVersion, escrowServiceVersion: _escrowServiceVersion, abandoned:false});
	}

	modifier onlyOwner() {
    	require(msg.sender == admin.owner);
        _;
  	}
  	
  	modifier onlyWhenActive() {
    	require(admin.abandoned == false);
        _;
  	}
  	
  	function abandon() onlyOwner {
  	    admin.abandoned = true;
  	}
  	
  	function abandonListingService(uint serviceVersion) onlyOwner {
  	    AbstractService(listingServices[serviceVersion]).abandon();
  	}
  	
  	function abandonEscrowService(uint serviceVersion) onlyOwner {
  	    AbstractService(escrowServices[serviceVersion]).abandon();
  	}

  	function assignListingDB(address _listingDB) onlyOwner onlyWhenActive {
  	    ++admin.listingDBVersion;
  	    listingDBs[admin.listingDBVersion] = _listingDB;
  	}
  	
  	function getListingDB(uint8 _version) constant onlyWhenActive returns(address) {
  	    return listingDBs[_version];
  	}
  	
    function getListingService(uint8 _version) constant onlyWhenActive returns(address) {
  	    return listingServices[_version];
  	}

  	function authorizeListingService(address _listingService) onlyOwner onlyWhenActive {
  	    ++admin.listingServiceVersion;
  	    listingServices[admin.listingServiceVersion] = _listingService;
  	    address listingDB = getListingDB(admin.listingDBVersion);
   	    AbstractListingDB(listingDB).updateService(_listingService, escrowServices[admin.escrowServiceVersion]);
  	}
  	
  	function authorizeEscrowService(address _escrowService) onlyOwner onlyWhenActive {
  	    ++admin.escrowServiceVersion;
  	    escrowServices[admin.escrowServiceVersion] = _escrowService;
  	    address listingDB = getListingDB(admin.listingDBVersion);
   	    AbstractListingDB(listingDB).updateService(listingServices[admin.listingServiceVersion], _escrowService);
  	}

}