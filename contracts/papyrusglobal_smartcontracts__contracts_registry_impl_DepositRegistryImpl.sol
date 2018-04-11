pragma solidity ^0.4.18;

import '../../common/SafeMath.sol';
import "../../dao/DaoOwnable.sol";
import "../DepositRegistry.sol";


// This is the base contract that your contract DepositRegistry extends from.
contract DepositRegistryImpl is DepositRegistry, DaoOwnable {
  using SafeMath for uint256;

  // STRUCTURES

  // This struct keeps all data for a Deposit.
  struct Deposit {
    // Keeps the address of this record creator.
    address owner;
    // Keeps the time when this record was created.
    uint256 time;
    // Keeps the index of the keys array for fast lookup
    uint256 keysIndex;
    // Deposit left
    uint256 amount;
  }

  // PUBLIC FUNCTIONS

  // This is the function that actually insert a record. 
  function register(address key, uint256 amount, address depositOwner) public onlyDaoOrOwner {
    require(records[key].time == 0);
    records[key].time = now;
    records[key].owner = depositOwner;
    records[key].keysIndex = keys.length;
    keys.length++;
    keys[keys.length - 1] = key;
    records[key].amount = amount;
    numDeposits++;
  }

  // Unregister a given record
  function unregister(address key) public onlyDaoOrOwner {
    uint256 keysIndex = records[key].keysIndex;
    delete records[key];
    numDeposits--;
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

  function getDepositOwner(address key) public view returns (address) {
    return records[key].owner;
  }

  function getDeposit(address key) public view returns (uint256 amount) {
    Deposit storage record = records[key];
    amount = record.amount;
  }

  function getDepositRecord(address key) public view returns (address owner, uint256 time, uint256 amount, address depositOwner) {
    Deposit storage record = records[key];
    owner = record.owner;
    time = record.time;
    amount = record.amount;
    depositOwner = record.owner;
  }

  function hasEnough(address key, uint256 amount) public view returns (bool) {
    Deposit storage deposit = records[key];
    return deposit.amount >= amount;
  }

  function spend(address key, uint256 amount) public onlyDaoOrOwner {
    require(isRegistered(key));
    records[key].amount = records[key].amount.sub(amount);
  }

  function refill(address key, uint256 amount) public onlyDaoOrOwner {
    require(isRegistered(key));
    records[key].amount = records[key].amount.add(amount);
  }

  function kill() public onlyOwner {
    selfdestruct(owner);
  }

  // FIELDS

  uint256 public creationTime = now;

  // This mapping keeps the records of this Registry.
  mapping(address => Deposit) records;

  // Keeps the total numbers of records in this Registry.
  uint256 public numDeposits;

  // Keeps a list of all keys to interate the records.
  address[] public keys;
}
