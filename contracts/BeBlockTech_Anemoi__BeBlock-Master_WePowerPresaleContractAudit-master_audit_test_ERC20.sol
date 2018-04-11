pragma solidity ^0.4.11;

contract ERC20 {
  /// @notice Send `_amount` tokens to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _amount The amount of tokens to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _amount) returns (bool success);

  /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
  ///  is approved by `_from`
  /// @param _from The address holding the tokens being transferred
  /// @param _to The address of the recipient
  /// @param _amount The amount of tokens to be transferred
  /// @return True if the transfer was successful
  function transferFrom(address _from, address _to, uint256 _amount
  ) returns (bool success);

  /// @param _owner The address that's balance is being requested
  /// @return The balance of `_owner` at the current block
  function balanceOf(address _owner) constant returns (uint256 balance);

  /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
  ///  its behalf. This is a modified version of the ERC20 approve function
  ///  to be a little bit safer
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _amount The amount of tokens to be approved for transfer
  /// @return True if the approval was successful
  function approve(address _spender, uint256 _amount) returns (bool success);

  /// @dev This function makes it easy to read the `allowed[]` map
  /// @param _owner The address of the account that owns the token
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens of _owner that _spender is allowed
  ///  to spend
  function allowance(address _owner, address _spender
  ) constant returns (uint256 remaining);

  /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
  ///  its behalf, and then a function is triggered in the contract that is
  ///  being approved, `_spender`. This allows users to use their tokens to
  ///  interact with contracts in one function call instead of two
  /// @param _spender The address of the contract able to transfer the tokens
  /// @param _amount The amount of tokens to be approved for transfer
  /// @return True if the function call was successful
  function approveAndCall(address _spender, uint256 _amount, bytes _extraData
  ) returns (bool success);

  /// @dev This function makes it easy to get the total number of tokens
  /// @return The total number of tokens
  function totalSupply() constant returns (uint);
}
