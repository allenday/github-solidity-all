pragma solidity ^0.4.4;
 
contract AbstractENSRegistrar {
    function entries(bytes32 _hash) constant returns (uint, address, uint, uint, uint);
    function transfer(bytes32 _hash, address newOwner);
}
 
contract AbstractDeed {
    address public owner;
    address public previousOwner;
}

contract AbstractListingDB {
    enum BidStatus {blank, bid, accepted, declined, escrowed}
    function getBidInfo(uint64 bidId) constant returns(bytes32 labelHash, BidStatus status, address bidder, uint bidAmount);
    function recordEscrowOnBid(uint64 _optionalBidId, uint64 _escrowId);
} 
 
contract EscrowService {
   
    enum EscrowStatus {blank, started, domainTransferred, escrowRejected, settled, escrowWithdrawn, escrowScavenged}
 
    struct EscrowDeed {
        bytes32 labelHash;
        address bidder;
        address nameDeedOrigOwner;
        uint paymentAmount;
        uint goodUntil;
        EscrowStatus status;
    }
 
    struct Admin {
        //ENS Name Registrar
        address ensRegistrar;
        //Owner of the Escrow contract.
        address owner;
        address registry;
        uint offerLength;
        uint scavengeLength;
        //address of listingDB for bid verification
        AbstractListingDB listingDB;
        //Only the funds in the tips jar is at risk even when the owner's keys are compromised.
        uint tipsBalance;
        //unique sequence
        uint64 nextEscrowId;
        //Kill switch. Once a contract is deactivated, it wont allow new escrows, while existing ones can continue to process.
        bool abandoned;
    }
   
    Admin public admin;
    mapping(uint64 => EscrowDeed) public escrows;
   
    modifier onlyWhenActive() {
        require(admin.abandoned == false);
        _;
    }
   
    modifier onlyByOwner() {
        require(admin.owner == msg.sender);
        _;
    }
    
    modifier onlyByRegistry() {
  	    require(msg.sender == address(admin.registry));
        _;
  	}
   
    function EscrowService(address _ensRegistrar, address _registry, AbstractListingDB _listingDB, uint _offerLength, uint _scavengeLength, uint64 _startingEscrowId) {
        admin = Admin({abandoned: false, owner:msg.sender, registry: _registry, ensRegistrar: _ensRegistrar,listingDB: _listingDB, 
                offerLength: _offerLength, scavengeLength: _scavengeLength, nextEscrowId: _startingEscrowId, tipsBalance:0});
    }
    
    function getAdminInfo() constant returns(address ensRegistrar, address owner, address registry, uint offerLength, 
		uint scavengeLength, address listingDB, uint tipsBalance, uint64 nextEscrowId, bool abandoned) {
			return (admin.ensRegistrar, admin.owner, admin.registry, admin.offerLength, admin.scavengeLength, admin.listingDB, admin.tipsBalance, admin.nextEscrowId, admin.abandoned);
	}
   
    //Dont accept payments that are not tied to transactions. Sorry, not interested. 
    function () {
        FallbackCalled();
    }
    
    function nextEscrowId() constant returns (uint64) {
        return (admin.nextEscrowId);
    }
    
    function abandon() onlyByRegistry {
        admin.abandoned = true;
    }
   
    function startEscrow(string _name, uint _paymentAmount, uint64 _optionalBidId) payable onlyWhenActive returns (uint64 escrowId) {
        //ethers sent should be atleast equal to payment amount, and tip cant be more than 10%
        require(msg.value >= _paymentAmount && msg.value <= (_paymentAmount * 11)/10 );
        bytes32 labelHash = sha3(_name);
        if(_optionalBidId > 0) {
            var (labelHashOnBid, statusOnBid, bidderOnBid, bidAmountOnBid) = admin.listingDB.getBidInfo(_optionalBidId);
            if(labelHashOnBid != labelHash || msg.sender != bidderOnBid || _paymentAmount != bidAmountOnBid 
                || statusOnBid == AbstractListingDB.BidStatus.declined || msg.value > (bidAmountOnBid * 11)/10 ) 
                throw;
        }

        escrowId = admin.nextEscrowId++;
        EscrowDeed memory escrow = EscrowDeed({labelHash:labelHash, bidder:msg.sender, nameDeedOrigOwner:0x00, 
                    paymentAmount:_paymentAmount, goodUntil: now + admin.offerLength, status: EscrowStatus.started});
        escrows[escrowId] = escrow;
        admin.tipsBalance += (msg.value - _paymentAmount);
        if(_optionalBidId > 0) {
            admin.listingDB.recordEscrowOnBid(_optionalBidId, escrowId);
        }
        EscrowPosted(escrowId, _name);
        return escrowId;
    }
    
    function escrowDeed(uint64 escrowId) constant returns (bytes32 labelHash, address bidder, address nameDeedOrigOwner, uint paymentAmount, uint goodUntil, EscrowStatus status) {
        var escrow = escrows[escrowId];
        return (escrow.labelHash, escrow.bidder, escrow.nameDeedOrigOwner, escrow.paymentAmount, escrow.goodUntil, escrow.status);
    }
   
    //any one can initiate the rescue, so no need to bring the master key from cold storage
    function scavengeEscrow(uint64 escrowId) {
        EscrowDeed escrow = escrows[escrowId];
        require(escrow.goodUntil + admin.scavengeLength < now);
        require(escrow.status == EscrowStatus.started || escrow.status == EscrowStatus.domainTransferred || escrow.status == EscrowStatus.escrowRejected);
        escrow.status = EscrowStatus.escrowScavenged;
        admin.tipsBalance += (escrow.paymentAmount);
        EscrowScavenged(escrow.labelHash, escrowId);
    }

    function withdrawTip(uint requestAmt) payable onlyByOwner {
        require(requestAmt <= admin.tipsBalance);
        admin.tipsBalance -= requestAmt;
        admin.owner.transfer(requestAmt);
    }
   
    function withdrawEscrow(uint64 escrowId) payable {
        EscrowDeed escrow = escrows[escrowId];
 
        require(msg.sender ==escrow.bidder);  //who
        //can withdraw rightway if escrow is already rejected
        require((escrow.goodUntil < now && escrow.status == EscrowStatus.started) ||  escrow.status == EscrowStatus.escrowRejected);  //under what circumstances

        escrow.status = EscrowStatus.escrowWithdrawn;
        //send funds to bidder;
        admin.tipsBalance += (msg.value);
        escrow.bidder.transfer(escrow.paymentAmount);
        EscrowWithdrawn(escrow.labelHash, escrowId);
    }
   
    function drawFundsAfterTransfer(uint64 escrowId) payable {
        EscrowDeed escrow = escrows[escrowId];
        require(msg.sender == escrow.nameDeedOrigOwner);
        require(escrow.status == EscrowStatus.domainTransferred);

        escrow.status = EscrowStatus.settled;
        //send funds to original name owner
        admin.tipsBalance += (msg.value);
        escrow.nameDeedOrigOwner.transfer(escrow.paymentAmount);
        FundsDrawnByNameDeedOwner(escrow.labelHash, escrowId);
    }
   
    function reject(uint64 escrowId, string reason) payable {
        EscrowDeed escrow = escrows[escrowId];
       
        var (,_deedAddr,,,) = AbstractENSRegistrar(admin.ensRegistrar).entries(escrow.labelHash);
        var deed = AbstractDeed(_deedAddr);
        require(escrow.goodUntil > now);
        require(escrow.status != EscrowStatus.domainTransferred);                      //under what circumstances
        require(escrow.status != EscrowStatus.settled);
        require((address(this) == deed.owner() && msg.sender == deed.previousOwner()) || msg.sender == deed.owner());

        escrow.status = EscrowStatus.escrowRejected;
        admin.tipsBalance += (msg.value);
        EscrowRejected(escrow.labelHash, escrowId, reason);
    }
   
    function transferDomainToBuyer(uint64 escrowId) payable {
        //transfer domain ownership, note down the original owner
        //mark balance ready for withdrawal by moving the status
        EscrowDeed escrow = escrows[escrowId];
       
        var (,_deedAddr,,,) = AbstractENSRegistrar(admin.ensRegistrar).entries(escrow.labelHash);
        var deed = AbstractDeed(_deedAddr);
        require(address(this) == deed.owner());
        require(msg.sender == deed.previousOwner());
        require(escrow.goodUntil > now);
        require(escrow.status == EscrowStatus.started);
        
        AbstractENSRegistrar(admin.ensRegistrar).transfer(escrow.labelHash, escrow.bidder);
        escrow.nameDeedOrigOwner = msg.sender;
        escrow.status = EscrowStatus.domainTransferred;
        admin.tipsBalance += (msg.value);
        DomainTransferred(escrow.labelHash, escrowId);
    }
    
    function transferDomainBackToSeller(string _name) payable {
        bytes32 labelHash = sha3(_name);
        var (,_deedAddr,,,) = AbstractENSRegistrar(admin.ensRegistrar).entries(labelHash);
        var deed = AbstractDeed(_deedAddr);
        require(address(this) == deed.owner());
        require(msg.sender == deed.previousOwner());
        AbstractENSRegistrar(admin.ensRegistrar).transfer(labelHash, deed.previousOwner());
        admin.tipsBalance += (msg.value);
        DomainTransferredBackToOwner(_name);
    }
 
   
    event FallbackCalled();
    event EscrowPosted(uint64 escrowId, string name);
    event EscrowScavenged(bytes32 labelHash, uint64 escrowId);
    event EscrowRejected(bytes32 labelHash, uint64 escrowId, string reason);
    event DomainTransferred(bytes32 labelHash, uint64 escrowId);
    event DomainTransferredBackToOwner(string name);
    event FundsDrawnByNameDeedOwner(bytes32 labelHash, uint64 escrowId);
    event EscrowWithdrawn(bytes32 labelHash, uint64 escrowId);
 
}