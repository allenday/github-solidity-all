pragma solidity ^0.4.16;


contract IMiniMeToken {
  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) returns (bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

  /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of tokens to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);

  function generateTokens(address _to, uint256 _value) public returns (bool success);
  function destroyTokens(address _owner, uint _amount) public returns (bool);
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success);
  function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled) public returns(address);

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) public constant returns (uint256 balance);
  function enableTransfers(bool _transfersEnabled) public;

  function balanceOfAt(address _owner, uint256 _blockNumber) public constant returns (uint256);
  function balanceOfAtTime(address _owner, uint256 _time) public constant returns (uint256);

  function totalSupply() public constant returns (uint256);
  function totalSupplyAt(uint256 _blockNumber) public constant returns (uint256);
  function totalSupplyAtTime(uint256 _time) public constant returns (uint256);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
