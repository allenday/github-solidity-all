pragma solidity ^0.4.11;

import "./DisputeInterface.sol";
import "../oraclize-ethereum-api/oraclizeAPI_0.4.sol";

contract DisputeResolver is usingOraclize {

  // list of owners
  address[256] owners;
  // index on the list of owners to allow reverse lookup
  mapping(address => uint) ownerIndex;

  uint public oraclizeGasLimit;

  // simple single-sig function modifier.
  modifier onlyOwner {
    require(isOwner(msg.sender));
    _;
  }

  struct DisputeAssignment {
    address assignee;
    address seller;
  }

  mapping(string => DisputeAssignment) disputes;

  struct Dispute {
    address seller;
    string uid;
  }

  mapping(bytes32 => Dispute) public disputeQueryIds;

  DisputeInterface disputeInterface;

  //note: sets msg.sender as owner
  function DisputeResolver(address[] _owners, address _disputeInterface) {
    owners[1] = msg.sender;
    ownerIndex[msg.sender] = 1;
    for (uint i = 0; i < _owners.length; ++i) {
      owners[2 + i] = _owners[i];
      ownerIndex[_owners[i]] = 2 + i;
    }

    disputeInterface = DisputeInterface(_disputeInterface);
    oraclizeGasLimit = 200000;
  }

  function setOraclizeGasPrice(uint gasPrice) onlyOwner {
    oraclize_setCustomGasPrice(gasPrice);
  }

  function setOraclizeGasLimit(uint gasLimit) onlyOwner {
    oraclizeGasLimit = gasLimit;
  }

  function() payable {

  }

  function withdraw(uint amount) onlyOwner {
      msg.sender.transfer(amount);
  }

  event DisputeAssigned(address seller, string uid, address assignee, address assigner);
  event DisputeEscalated(address seller, string uid, address assignee, address assigner);
  event DisputeResolved(address seller, string uid, string resolvedTo, address assignee);

  function assignDispute(string _uid, address _seller, string country) onlyOwner {
    assignDispute(_uid, _seller, country, msg.sender);
  }

  function assignDispute(string _uid, address _seller, string country, address assignee) onlyOwner {
    require(!isContract(assignee));
    bytes32 queryId = oraclize_query("URL", "json(https://us-central1-automteetherexchange.cloudfunctions.net/checkDispute).dispute", strConcat('\n{"country" :"', country, '", "orderId": "', _uid, '"}'), oraclizeGasLimit);
    disputeQueryIds[queryId].uid = _uid;
    disputeQueryIds[queryId].seller = _seller;

    disputes[_uid].assignee = assignee;
    disputes[_uid].seller = _seller;
    DisputeAssigned(_seller, _uid, assignee, msg.sender);
  }

  function __callback(bytes32 id, string result) {
    if(msg.sender != oraclize_cbAddress() || strCompare(disputeQueryIds[id].uid, "VOID") == 0) throw;
    if(strCompare(result, "true") == 0) {
      disputeInterface.setDisputed(disputeQueryIds[id].seller, disputeQueryIds[id].uid);
    }
    disputeQueryIds[id].uid = "VOID";
  }

  function resolveDisputeSeller(string uid) onlyAssignee(uid) {
    disputeInterface.resolveDisputeSeller(uid, disputes[uid].seller);
    DisputeResolved(disputes[uid].seller, uid, 'seller', msg.sender);
  }

  function resolveDisputeBuyer(string uid) onlyAssignee(uid) {
    disputeInterface.resolveDisputeBuyer(uid, disputes[uid].seller);
    DisputeResolved(disputes[uid].seller, uid, 'buyer', msg.sender);
  }

  modifier onlyAssignee(string uid) {
    require(disputes[uid].assignee == msg.sender || isOwner(msg.sender));
    _;
  }

  // Gets an owner by 0-indexed position (using numOwners as the count)
  function getOwner(uint ownerIndex) external constant returns (address) {
    return address(owners[ownerIndex + 1]);
  }

  function isOwner(address _addr) constant returns (bool) {
    return ownerIndex[_addr] > 0;
  }

  function isContract(address addr) internal returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}
