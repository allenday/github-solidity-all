pragma solidity ^0.4.10;
contract Registrar {
    function entries(bytes32 _hash) constant returns (uint, address, uint, uint, uint);
    function transfer(bytes32 _hash, address newOwner);
}

contract Deed {
    address public registrar;
    function getCreationDate() constant returns(uint);
    uint public creationDate;
    address public owner;
    address public previousOwner;
    uint public value;
    function Deed(address _owner);
    function setOwner(address newOwner);
    function setRegistrar(address newRegistrar);
    function setBalance(uint newValue, bool throwOnFailure);
    function closeDeed(uint refundRatio);
    function destroyDeed();
}

contract ENSTrade {
    struct Record {
        string name;
        bool listed;
        uint buyPrice;
        bytes32 nextRecord;
        bytes32 previousRecord;
        string message;
    }

    struct RecordOffers {
        address lastOffer;
        uint totalOfferCount;
        uint totalOfferValue;
    }

    struct Offer {
        address nextOffer;
        address previousOffer;
        uint value;
        string message;
    }

    event TradeComplete(bytes32 indexed hash, address from, address to, uint256 value);
    event OfferCreated(bytes32 indexed hash, address from, uint256 value);
    event OfferCancelled(bytes32 indexed hash, address from);
    event ListingCreated(string indexed name, address from, uint256 buyPrice);
    event ListingRemoved(bytes32 indexed hash, address from);
    event RecordReclaimed(bytes32 indexed hash, address to);

    address feeAddress;
    uint public fee = 0; // Out of 10000 (0% for alpha)
    uint public minimumOfferPrice = 0.01 ether;

    uint public recordsCurrentlyListed;
    uint public totalRecordsTraded;
    uint public totalValueTraded;

    Registrar registrar;

    mapping (bytes32 => Record) records;
    mapping (bytes32 => mapping (address => Offer)) offers;
    mapping (bytes32 => RecordOffers) recordOffers;
    bytes32 public lastRecord;

    modifier onlyOwner(bytes32 _hash) {
        // Check who owns the name using the previousOwner() function, as ens.trade should currently owns it.
        var (,_deedAddress,,,) = registrar.entries(_hash);
        Deed d = Deed(_deedAddress);
        if (d.owner() != address(this)) throw;
        if (d.previousOwner() != msg.sender) throw;
        _;
    }

    modifier onlyFeeAddress {
        if (msg.sender != feeAddress) throw;
        _;
    }

    function ENSTrade(Registrar _registrarAddress) {
        feeAddress = msg.sender;
        registrar = Registrar(_registrarAddress);
    }
    function setFeeAddress(address _feeAddress) onlyFeeAddress {
        feeAddress = _feeAddress;
    }
    function setMinimumOfferPrice(uint _minimumOfferPrice) onlyFeeAddress {
        minimumOfferPrice = _minimumOfferPrice;
    }
    function setFee(uint _fee) onlyFeeAddress {
        if (_fee > 500) throw; // Maximum 5%
        fee = _fee;
    }

    function sha(string _string) constant returns(bytes32) {
        return sha3(_string);
    }

    function newListing(string _name, uint256 _buyPrice, string _message) {
        // Hashes the name and checks that the sender previously owned it
        bytes32 _hash = sha3(_name);
        Deed d = getDeed(_hash);
        if (d.owner() != address(this)) throw;
        if (d.previousOwner() != msg.sender) throw;
        if (_buyPrice == 0 || _buyPrice < minimumOfferPrice) throw; // For extra security

        Record r = records[_hash];
        if (lastRecord != 0x0) {
            records[lastRecord].nextRecord = _hash;
        }
        r.previousRecord = lastRecord;
        r.listed = true;
        r.name = _name;
        r.buyPrice = _buyPrice;
        r.message = _message;
        lastRecord = _hash;
        recordsCurrentlyListed++;

        ListingCreated(_name, msg.sender, _buyPrice);
    }

    function deList(bytes32 _hash) onlyOwner(_hash) {
        Record r = records[_hash];
        if (r.listed) {
            deleteRecord(_hash);
            ListingRemoved(_hash, msg.sender);
        }
    }

    function reclaim(bytes32 _hash) onlyOwner(_hash) {
        Record r = records[_hash];
        registrar.transfer(_hash, msg.sender);
        if (r.listed) {
            deleteRecord(_hash);
            ListingRemoved(_hash, msg.sender);
        }
        RecordReclaimed(_hash, msg.sender);
    }

    function deleteRecord(bytes32 _hash) internal {
        Record r = records[_hash];
        records[r.previousRecord].nextRecord = r.nextRecord;
        if (_hash == lastRecord) {
            lastRecord = r.previousRecord;
        }
        delete records[_hash];
        recordsCurrentlyListed--;
    }

    function newOffer(bytes32 _hash, string _message) payable {
        if (msg.value == 0) throw;
        Offer o = offers[_hash][msg.sender];
        if (o.value > 0) throw; // Offer exists
        Record r = records[_hash];
        if (msg.value >= r.buyPrice && r.buyPrice != 0) {
            // Offer is above asking price, finish trade
            transferRecord(_hash, msg.sender, msg.value);
            return;
        }
        if (msg.value < minimumOfferPrice) throw;
        o.value = msg.value;
        o.message = _message;

        RecordOffers ro = recordOffers[_hash];
        if (ro.lastOffer != 0x0) {
            offers[_hash][ro.lastOffer].nextOffer = msg.sender;
        }
        o.previousOffer = ro.lastOffer;
        ro.lastOffer = msg.sender;
        ro.totalOfferCount++;
        ro.totalOfferValue += msg.value;

        OfferCreated(_hash, msg.sender, msg.value);
    }

    function cancelOffer(bytes32 _hash) {
        Offer o = offers[_hash][msg.sender];
        if (o.value == 0) throw;
        uint valueToSend = o.value;
        deleteOffer(_hash, msg.sender);
        msg.sender.transfer(valueToSend);

        OfferCancelled(_hash, msg.sender);
    }

    function acceptOffer(bytes32 _hash, address _offerAddress, uint256 _offerValue) onlyOwner(_hash) {
        Offer o = offers[_hash][_offerAddress];
        if (o.value != _offerValue || o.value == 0) throw; // For extra security and race conditions

        Record r = records[_hash];
        if (!r.listed) throw;

        transferRecord(_hash, _offerAddress, o.value);
        deleteOffer(_hash, _offerAddress);
    }

    function deleteOffer(bytes32 _hash, address _offerAddress) internal {
        RecordOffers ro = recordOffers[_hash];
        Offer o = offers[_hash][_offerAddress];
        offers[_hash][o.previousOffer].nextOffer = o.nextOffer;
        if (ro.lastOffer == _offerAddress) {
            ro.lastOffer = o.previousOffer;
        }
        ro.totalOfferCount--;
        ro.totalOfferValue -= offers[_hash][_offerAddress].value;
        delete offers[_hash][_offerAddress];
    }

    function getDeed(bytes32 _hash) constant internal returns (Deed) {
        var (,_deedAddress,,,) = registrar.entries(_hash);
        return Deed(_deedAddress);
    }

    function transferRecord(bytes32 _hash, address _toAddress, uint256 _value) internal {
        uint _fee = _value * fee / 10000;
        // Deed d = Deed(_deedAddress);
        totalRecordsTraded++;
        totalValueTraded += _value;

        Deed d = getDeed(_hash);
        address _previousOwner = d.previousOwner();

        registrar.transfer(_hash, _toAddress);
        deleteRecord(_hash);

        _previousOwner.transfer(_value - _fee);
        feeAddress.transfer(_fee);

        TradeComplete(_hash, _previousOwner, _toAddress, _value);
    }

    function getBuyPriceAndPreviousRecord(bytes32 _hash) constant returns (uint256, bytes32) {
        // For quick iterating on the home page
        Record r = records[_hash];
        return (r.buyPrice, r.previousRecord);
    }

    function getRecord(bytes32 _hash) constant returns(bool, string, uint256, bytes32, bytes32, string) {
        Record r = records[_hash];
        return (r.listed, r.name, r.buyPrice, r.nextRecord, r.previousRecord, r.message);
    }

    function getDeedInfo(address _deedAddress) constant returns(address, address, uint256, uint256) {
        // For speed, rather than calling as seperate calls to the registrar
        Deed d = Deed(_deedAddress);
        return (d.owner(), d.previousOwner(), d.value(), d.creationDate());
    }

    function getFullRecord(bytes32 _hash) constant returns(bool, string, uint256, bytes32, bytes32, string, address, address, uint256, uint256) {
        Record r = records[_hash];
        Deed d = getDeed(_hash);
        return (r.listed, r.name, r.buyPrice, r.nextRecord, r.previousRecord, r.message, d.owner(), d.previousOwner(), d.value(), d.creationDate());
    }

    function getRecordOffers(bytes32 _hash) constant returns(address, uint256, uint256) {
        RecordOffers ro = recordOffers[_hash];
        return (ro.lastOffer, ro.totalOfferCount, ro.totalOfferValue);
    }

    function getOffer(bytes32 _hash, address _offerAddress) constant returns(address, address, uint256, string) {
        Offer o = offers[_hash][_offerAddress];
        return (o.nextOffer, o.previousOffer, o.value, o.message);
    }
}
