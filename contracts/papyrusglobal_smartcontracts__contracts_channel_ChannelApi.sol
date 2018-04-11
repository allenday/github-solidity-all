pragma solidity ^0.4.18;


contract ChannelApi {
  function applyRuntimeUpdate(address from, address to, uint64 totalImpressions, uint64 fraudImpressions) public;
  function applyAuditorsCheckUpdate(address from, address to, uint64 fraudImpressionsDelta) public;
}
