pragma solidity ^0.4.16;


contract IMembershipRegistry {
  function members(uint256 _id) public constant returns (address);
  function ids(address _member) public constant returns (uint256);
  function isMember(address _member) public constant returns (bool);
  function numMembers() public constant returns (uint256);
  function numActiveMembers() public constant returns (uint256);
  function transfer(address _addr) public;
  function addMember(address _member) public;
  function removeMember(address _member) public;
}
