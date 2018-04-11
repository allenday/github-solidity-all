pragma solidity ^0.4.18;

import "../../dao/DaoOwnable.sol";
import "../PublisherRegistry.sol";


contract PublisherRegistryImpl is PublisherRegistry, DaoOwnable {

  // STRUCTURES

  // This struct keeps all data for a publisher.
  struct Publisher {
    // Keeps the address of this record creator.
    address owner;
    // Keeps the time when this record was created.
    uint256 time;
    // Keeps the index of the keys array for fast lookup
    uint256 keysIndex;
    // publisher Address
    address publisherAddress;

    bytes32[5] url;

    uint256[2] karma;
  }

  // PUBLIC FUNCTIONS

  // This is the function that actually insert a record.
  function register(address key, bytes32[5] url, address recordOwner) public onlyDaoOrOwner {
    require(records[key].time == 0);
    records[key].time = now;
    records[key].owner = recordOwner;
    records[key].keysIndex = keys.length;
    records[key].publisherAddress = key;
    records[key].url = url;
    keys.length++;
    keys[keys.length - 1] = key;
    numRecords++;
  }

  // Updates the values of the given record.
  function updateUrl(address key, bytes32[5] url, address sender) public onlyDaoOrOwner {
    // Only the owner can update his record.
    require(records[key].owner == sender);
    records[key].url = url;
  }


  function applyKarmaDiff(address key, uint256[2] diff) public onlyDaoOrOwner {
    Publisher storage publisher = records[key];
    publisher.karma[0] += diff[0];
    publisher.karma[1] += diff[1];
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

  function getPublisher(address key) public view returns (address publisherAddress, bytes32[5] url, uint256[2] karma, address recordOwner) {
    Publisher storage record = records[key];
    publisherAddress = record.publisherAddress;
    url = record.url;
    karma = record.karma;
    recordOwner = record.owner;
  }

  // Returns the owner of the given record. The owner could also be get
  // by using the function getDSP but in that case all record attributes
  // are returned.
  function getOwner(address key) public view returns (address) {
    return records[key].owner;
  }

  // Returns the registration time of the given record. The time could also
  // be get by using the function getDSP but in that case all record attributes
  // are returned.
  function getTime(address key) public view returns (uint256) {
    return records[key].time;
  }

  //@dev Get list of all registered publishers
  //@return Returns array of addresses registered as DSP with register times
  function getAllPublishers() public view returns (address[] addresses, bytes32[5][] urls, uint256[2][] karmas, address[] recordOwners) {
    addresses = new address[](numRecords);
    urls = new bytes32[5][](numRecords);
    karmas = new uint256[2][](numRecords);
    recordOwners = new address[](numRecords);
    uint256 i;
    for (i = 0; i < numRecords; i++) {
      Publisher storage publisher = records[keys[i]];
      addresses[i] = publisher.publisherAddress;
      urls[i] = publisher.url;
      karmas[i] = publisher.karma;
      recordOwners[i] = publisher.owner;
    }
  }

  function kill() public onlyOwner {
      selfdestruct(owner);
  }

  // FIELDS

  // This mapping keeps the records of this Registry.
  mapping(address => Publisher) records;

  // Keeps the total numbers of records in this Registry.
  uint256 public numRecords;

  // Keeps a list of all keys to interate the records.
  address[] public keys;
}
