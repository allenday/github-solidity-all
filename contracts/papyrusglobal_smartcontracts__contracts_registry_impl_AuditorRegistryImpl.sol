pragma solidity ^0.4.18;

import "../../dao/DaoOwnable.sol";
import "../AuditorRegistry.sol";


// This is the base contract that your contract AuditorRegistry extends from.
contract AuditorRegistryImpl is AuditorRegistry, DaoOwnable {

  // STRUCTURES

  // This struct keeps all data for a Auditor.
  struct Auditor {
    // Keeps the address of this record creator.
    address owner;
    // Keeps the time when this record was created.
    uint256 time;
    // Keeps the index of the keys array for fast lookup
    uint256 keysIndex;
    // Auditor Address
    address auditorAddress;

    uint256[2] karma;
  }

  // PUBLIC FUNCTIONS

  // This is the function that actually insert a record.
  function register(address key, address recordOwner) public onlyDaoOrOwner {
    require(records[key].time == 0);
    records[key].time = now;
    records[key].owner = recordOwner;
    records[key].keysIndex = keys.length;
    records[key].auditorAddress = key;
    keys.length++;
    keys[keys.length - 1] = key;
    numRecords++;
  }

  function applyKarmaDiff(address key, uint256[2] diff) public onlyDaoOrOwner {
    Auditor storage auditor = records[key];
    auditor.karma[0] += diff[0];
    auditor.karma[1] += diff[1];
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

  function getAuditor(address key) public view returns (address auditorAddress, uint256[2] karma, address recordOwner) {
    Auditor storage record = records[key];
    auditorAddress = record.auditorAddress;
    karma = record.karma;
    recordOwner = record.owner;
  }

  // Returns the owner of the given record. The owner could also be get
  // by using the function getAuditor but in that case all record attributes
  // are returned.
  function getOwner(address key) public view returns (address) {
    return records[key].owner;
  }

  // Returns the registration time of the given record. The time could also
  // be get by using the function getAuditor but in that case all record attributes
  // are returned.
  function getTime(address key) public view returns (uint256) {
    return records[key].time;
  }

  //@dev Get list of all registered auditor
  //@return Returns array of addresses registered as Auditor with register times
  function getAllAuditors() public view returns (address[] addresses, uint256[2][] karmas, address[] recordOwners) {
    addresses = new address[](numRecords);
    karmas = new uint256[2][](numRecords);
    recordOwners = new address[](numRecords);
    uint256 i;
    for (i = 0; i < numRecords; i++) {
      Auditor storage auditor = records[keys[i]];
      addresses[i] = auditor.auditorAddress;
      karmas[i] = auditor.karma;
      recordOwners[i] = auditor.owner;
    }
  }

  function kill() public onlyOwner {
      selfdestruct(owner);
  }

  // FIELDS

  uint256 public creationTime = now;

  // This mapping keeps the records of this Registry.
  mapping(address => Auditor) records;

  // Keeps the total numbers of records in this Registry.
  uint256 public numRecords;

  // Keeps a list of all keys to interate the records.
  address[] public keys;
}
