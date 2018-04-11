// ===========================================
/*
 * Author: Brett Harvey
 * Name: Matchpool
 * Date: n/a
 * License: MIT
 */
// ===========================================

pragma solidity ^0.4.15;

contract MatchpoolAdministrator {
  address public MatchpoolAdmin;

  function MatchpoolAdministrator() {
    MatchpoolAdmin = msg.sender;
  }

  modifier MatchpoolAdministratorOnly() {
    require(msg.sender == MatchpoolAdmin);
    _;
  }
}

contract Matchpool is MatchpoolAdministrator {
  address public poolOwner;
  uint256 public TotalSupply;
  uint256 public PoolCreationFee;
  uint256 entranceFee;

  mapping (address => mapping (string => string)) MyPool;
  mapping (address => uint) public Guppy;
  mapping (address => mapping (string => uint256)) EntranceFee;
  mapping (string => bool) isActivePool;
  mapping (address => mapping (string => bool)) isPoolOwner;
  mapping (address => mapping (string => bool)) isPoolCoOwner;

  event MatchpoolEvent(string descriptio);
  event PoolAction(string PoolName, address User, string Action);
  event NewPoolCreated(string Name_, string descript, address PoolOwner_);
  event GuppyTransaction(address Sender, address Receiver, uint256 Amount);
  event AdministratorAction(address admin, string action, uint256 _amount);

  function Matchpool() {
    MatchpoolAdmin = msg.sender;
    TotalSupply = 1000000;
    Guppy[this] = 0;
    MatchpoolEvent("Contract Has Been Deployed");
  }

  modifier OwnerOnly(string isPoolName) {
    require(isPoolOwner[msg.sender][isPoolName] == true);
    _;
  }

  function CreateAPool(string _NameOfPool, string DescriptionOfPool) returns (bool) {
    if(Guppy[msg.sender] >= PoolCreationFee) {
      Guppy[msg.sender] -= PoolCreationFee;
      Guppy[this] += PoolCreationFee;
      MyPool[msg.sender][_NameOfPool] = DescriptionOfPool;
      isPoolOwner[msg.sender][_NameOfPool] = true;
      NewPoolCreated(_NameOfPool,DescriptionOfPool,msg.sender);
      return true;
    }
    MatchpoolEvent("Pool Creation Failed");
    return false;
  }

  function MintTokens(address _target, uint256 _amount) MatchpoolAdministratorOnly {
    Guppy[_target] += _amount;
    TotalSupply += _amount;
    GuppyTransaction(this, _target, _amount);
  }

  function SetPoolCreationFee(uint256 _setFee) MatchpoolAdministratorOnly {
    PoolCreationFee = _setFee;
    AdministratorAction(msg.sender, "Set Pool Creation Fee", _setFee);
  }

  function DeletePool(string _nameOfPool) MatchpoolAdministratorOnly
  returns (bool) {
    if (isActivePool[_nameOfPool] == true) {
      isActivePool[_nameOfPool] = false;
      AdministratorAction(msg.sender,"Pool Deleted Successfully",0);
      return true;
    }
    return false;
  }

  function AddPoolMember(address _newMember, string _poolName) {
    PoolAction(_poolName, _newMember, "Added new member");
  }

  function RemovePoolMember(address _removeMember, string _name) OwnerOnly(_name) {
    PoolAction(_name, _removeMember, "Removed member");
  }

  function SetPoolEntryFee(string _PoolName, uint256 _Price) OwnerOnly(_PoolName) {
    EntranceFee[poolOwner][_PoolName] = _Price;
    PoolAction(_PoolName, poolOwner, "Added Entrace Fee");
  }

  function ChangePoolName(string _poolName, string _newName) OwnerOnly(_poolName) {
    PoolAction(_poolName, poolOwner, "Initiated Name Change");
    MyPool[this][_poolName] = _newName;
    PoolAction(_poolName, poolOwner, "Name Change Complete");
  }

  function PayPoolEntranceFee(string name_) returns (bool) {
    if (Guppy[msg.sender] >= EntranceFee[poolOwner][name_]) {
      Guppy[msg.sender] -= EntranceFee[poolOwner][name_];
      Guppy[this] += EntranceFee[poolOwner][name_];
      GuppyTransaction(msg.sender, this, EntranceFee[poolOwner][name_]);
      PoolAction(name_, msg.sender, "Entrance Fee Paid");
      return true;
    }
    PoolAction(name_, msg.sender, "Guppy balance too low");
    return false;
  }

  function AddPoolCoOwner(string _nameOfPool, address newAdmin) OwnerOnly(_nameOfPool) {
    isPoolCoOwner[newAdmin][_nameOfPool] = true;
  }

  function RemovePoolCoOwner(string _namePool, address adminToRemove) OwnerOnly(_namePool) {
    isPoolCoOwner[adminToRemove][_namePool] = false;
  }

  function CheckPoolOwnership(string _poolname, address NameOfOwner) constant public returns (bool) {
    if (isPoolOwner[NameOfOwner][_poolname]) return true;
    return false;
  }

  function GetPoolEntranceFee(string _Name) constant public returns (uint256) {
    return EntranceFee[poolOwner][_Name];
  }
}
