pragma solidity ^0.4.16;

import "utils/ProxyBased.sol";
import "utils/IMembershipRegistry.sol";


contract MembershipRegistry is ProxyBased {
  uint256 public numMembers;
  uint256 public numActiveMembers;
  mapping(uint256 => address) public members;
  mapping(address => uint256) public ids;

  function _addMember(address _member) internal {
    require(!isMember(_member));
    ids[_member] = numMembers++;
    members[ids[_member]] = _member;
    numActiveMembers++;
  }

  function _removeMember(address _member) internal {
    require(isMember(_member));
    members[ids[_member]] = address(0);
    ids[_member] = 0;
    numActiveMembers--;
  }

  function addMember(address _member) public onlyProxy {
    _addMember(_member);
  }

  function removeMember(address _member) public onlyProxy {
    _removeMember(_member);
  }

  function transferAddress(address _addr) public {
    require(isMember(msg.sender));
    members[ids[msg.sender]] == _addr;
    ids[_addr] = ids[msg.sender];
    ids[msg.sender] = 0;
  }

  function isMember(address _member) public constant returns (bool) {
    return (members[ids[_member]] == _member && _member != address(0));
  }
}
