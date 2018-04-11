pragma solidity ^0.4.6;
contract VersionedBlob {

  struct Commit {
    uint64 time;
    address account;
    string message;
    bytes blob;    
  }

  struct Tag {
    uint32 commitId;
    string tag;
  }

  address public owner;
  address[] members;

  Commit[] public commits;
  Tag[] tags;

  event CommitEvent(uint commitId, string message);
  event TagEvent(uint indexed commitId, string tag);
  event UntagEvent(string tag);

  modifier isOwner {
    if (msg.sender == owner) _;
  }

  modifier isMember {
    for (uint i = 0; i < members.length; i++) {
      if (msg.sender == members[i]) _;
    }
  }

  function VersionedBlob() {
    owner = msg.sender;
  }

  function setOwner(address newOwner) isOwner {
    owner = newOwner;
  }

  function addMember(address member) isOwner {
    members[members.length++] = member;
  }

  function removeMember(address member) isOwner {
    for (uint i = 0; i < members.length; i++) {
      if (member == members[i]) {
        delete members[i];
      }
    }
  }

  function getMembers() isOwner constant returns (address[]) {
    return members;
  }

  function commit(bytes blob, string message) isMember returns (uint commitId) {
    commitId = commits.length++;
    commits[commitId] = Commit(uint64(now), msg.sender, message, blob);
    CommitEvent(commitId, message);
  }

  function checkOut(int i) constant returns (bytes) {
    if (i == -1) {
      i = int(commits.length) - 1;
    }
    return commits[uint(i)].blob;
  }

  function tag(uint commitId, string tag) {
    tags[tags.length++] = Tag(uint32(commitId), tag);
    TagEvent(commitId, tag);
  }

  function findTag(string tag) returns (int) {
    bytes32 hash = sha3(tag);
    for (uint i = 0; i < tags.length; i++) {
      // Not possible to compare strings directly yet.
      if (sha3(tags[i].tag) == hash) {
        return int(i);
      }
    }
    return -1;
  }

  function untag(string tag) {
    int i = findTag(tag);
    if (i != -1) {
      delete tags[uint(i)];
      UntagEvent(tag);
    }
  }

  function checkOutTag(string tag) constant returns (bytes) {
    int i = findTag(tag);
    if (i != -1) {
      return commits[tags[uint(i)].commitId].blob;
    }
  }

}