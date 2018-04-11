pragma solidity ^0.4.18;


/// @title ERC20 interface
/// @dev Full ERC20 interface described at https://github.com/ethereum/EIPs/issues/20.
contract ERC20 {

  // EVENTS

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // PUBLIC FUNCTIONS

  function transfer(address _to, uint256 _value) public returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function approve(address _spender, uint256 _value) public returns (bool);
  function balanceOf(address _owner) public view returns (uint256);
  function allowance(address _owner, address _spender) public view returns (uint256);

  // FIELDS

  uint256 public totalSupply;
}
