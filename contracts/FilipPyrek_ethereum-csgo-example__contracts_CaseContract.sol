pragma solidity ^0.4.2;

import "./zeppelin/Ownable.sol";

contract CaseContract is Ownable {

  struct Case {
    uint id;
    uint collectionId;
  }

  mapping (address => Case[]) internal cases;
  mapping (uint => address) internal caseOwner;

  function emit(address recipient, uint id, uint collectionId)
    external
    onlyOwner
  {
    if (caseOwner[id] != address(0)) throw;

    cases[recipient].push(Case({
      id: id,
      collectionId: collectionId
    }));
    caseOwner[id] = recipient;
  }

  function remove(uint id)
    external
    onlyOwner
  {
    address owner = caseOwner[id];
    if (owner == address(0)) throw;

    delete caseOwner[id];
    Case[] ownersCases = cases[owner];
    for (uint i = 0; i < ownersCases.length; i++)
      if (ownersCases[i].id == id) {
        delete cases[owner][i];
        return;
      }
  }

  function getById(uint id)
    external
    returns (uint caseId, uint collectionId)
  {
    address recipient = caseOwner[id];
    Case[] recipientsCases = cases[recipient];
    for (uint i = 0; i < recipientsCases.length; i++)
      if (recipientsCases[i].id == id)
        return (recipientsCases[i].id, recipientsCases[i].collectionId);
    throw;
  }

  function getByOwner(address owner, uint offset)
    external
    returns (uint maxOffset, uint[128] ids, uint[128] collectionIds)
  {
    maxOffset = this.getDepositSize(owner);
    uint caseLimit = maxOffset < 128 ? maxOffset : 128;
    for (uint i = 0; i < caseLimit; i++) {
      uint caseIndex = i + offset;
      if (caseIndex >= maxOffset) continue;
      ids[i] = cases[owner][caseIndex].id;
      collectionIds[i] = cases[owner][caseIndex].collectionId;
    }
    return (maxOffset, ids, collectionIds);
  }

  function getDepositSize(address owner)
    external
    returns (uint size)
  {
    return cases[owner].length;
  }

}
