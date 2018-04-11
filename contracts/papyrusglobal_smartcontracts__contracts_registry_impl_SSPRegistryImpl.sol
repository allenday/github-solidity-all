pragma solidity ^0.4.18;

import "../../dao/DaoOwnable.sol";
import "../SSPRegistry.sol";


// This is the base contract that your contract SSPRegistry extends from.
contract SSPRegistryImpl is SSPRegistry, DaoOwnable {

  // STRUCTURES

  // This struct keeps all data for a SSP.
  struct SSP {
    // Keeps the address of this record creator.
    address owner;
    // Keeps the time when this record was created.
    uint256 time;
    // Keeps the index of the keys array for fast lookup
    uint256 keysIndex;
    // SSP Address
    address sspAddress;

    SSPType sspType;

    uint16 publisherFee;

    uint256[2] karma;
  }

  // PUBLIC FUNCTIONS

  // This is the function that actually insert a record.
  function register(address key, SSPType sspType, uint16 publisherFee, address recordOwner) public onlyDaoOrOwner {
    require(records[key].time == 0);
    records[key].time = now;
    records[key].owner = recordOwner;
    records[key].keysIndex = keys.length;
    records[key].sspAddress = key;
    records[key].sspType = sspType;
    records[key].publisherFee = publisherFee;
    keys.length++;
    keys[keys.length - 1] = key;
    numRecords++;
  }

  // Updates the values of the given record.
  function updatePublisherFee(address key, uint16 newFee, address sender) public onlyDaoOrOwner {
    // Only the owner can update his record.
    require(records[key].owner == sender);
    records[key].publisherFee = newFee;
  }

  function applyKarmaDiff(address key, uint256[2] diff) public onlyDaoOrOwner {
    SSP storage ssp = records[key];
    ssp.karma[0] += diff[0];
    ssp.karma[1] += diff[1];
  }

  // Unregister a given record
  function unregister(address key, address sender) public onlyDaoOrOwner {
    require(records[key].owner == sender);
    uint256 keysIndex = records[key].keysIndex;
    delete records[key];
    numRecords--;
    keys[keysIndex] = keys[keys.length - 1];
    records[keys[keysIndex]].keysIndex = keysIndex;
    keys.length--;
  }

  // Transfer ownership of a given record.
  function transfer(address key, address newOwner, address sender) public onlyDaoOrOwner {
    require(records[key].owner == sender);
    records[key].owner = newOwner;
  }

  // Tells whether a given key is registered.
  function isRegistered(address key) public view returns (bool) {
    return records[key].time != 0;
  }

  function getSSP(address key) public view returns (address sspAddress, SSPType sspType, uint16 publisherFee, uint256[2] karma, address recordOwner) {
    SSP storage record = records[key];
    sspAddress = record.sspAddress;
    sspType = record.sspType;
    publisherFee = record.publisherFee;
    karma = record.karma;
    recordOwner = owner;
  }

  // Returns the owner of the given record. The owner could also be get
  // by using the function getSSP but in that case all record attributes
  // are returned.
  function getOwner(address key) public view returns (address) {
    return records[key].owner;
  }

  function getAllSSP() public view returns (address[] addresses, SSPType[] sspTypes, uint16[] publisherFees, uint256[2][] karmas, address[] recordOwners) {
    addresses = new address[](numRecords);
    sspTypes = new SSPType[](numRecords);
    publisherFees = new uint16[](numRecords);
    karmas = new uint256[2][](numRecords);
    recordOwners = new address[](numRecords);
    uint256 i;
    for (i = 0; i < numRecords; i++) {
      SSP storage ssp = records[keys[i]];
      addresses[i] = ssp.sspAddress;
      sspTypes[i] = ssp.sspType;
      publisherFees[i] = ssp.publisherFee;
      karmas[i] = ssp.karma;
      recordOwners[i] = ssp.owner;
    }
  }

  // Returns the registration time of the given record. The time could also
  // be get by using the function getSSP but in that case all record attributes
  // are returned.
  function getTime(address key) public view returns (uint256) {
    return records[key].time;
  }

  function kill() public onlyOwner {
    selfdestruct(owner);
  }

  // FIELDS

  uint256 public creationTime = now;

  // This mapping keeps the records of this Registry.
  mapping(address => SSP) records;

  // Keeps the total numbers of records in this Registry.
  uint256 public numRecords;

  // Keeps a list of all keys to interate the records.
  address[] public keys;
}
