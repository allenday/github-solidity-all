pragma solidity ^0.4.11;

contract ERCToken {
  /*
   *  Data structures
   */
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  uint256 public totalSupply;

  // Constructor
  function ERCToken (uint _totalSupply) {
    totalSupply = _totalSupply;
    balances[msg.sender] = _totalSupply;
  }

  /*
   *  Read and write storage functions
   */
  /// @dev Transfers sender's tokens to a given address. Returns success.
  /// @param _to Address of token receiver.
  /// @param _value Number of tokens to transfer.
  function transfer(address _to, uint256 _value) returns (bool success) {
		require(balanceOf(msg.sender) >= _value);
		balances[msg.sender] -= _value;
		balances[_to] += _value;
		return true;
  }

  /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
  /// @param _from Address from where tokens are withdrawn.
  /// @param _to Address to where tokens are sent.
  /// @param _value Number of tokens to transfer.
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
		require(allowance(_from, _to) >= _value && balanceOf(_from) >= _value);
		balances[_from] -= _value;
		balances[_to] += _value;
		allowed[_from][msg.sender] -= _value;
		return true;
  }

  /// @dev Returns number of tokens owned by given address.
  /// @param _owner Address of token owner.
  function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
  }

  /// @dev Sets approved amount of tokens for spender. Returns success.
  /// @param _spender Address of allowed account.
  /// @param _value Number of approved tokens.
  function approve(address _spender, uint256 _value) returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		return true;
  }

  /// @dev Returns number of allowed tokens for given address.
  /// @param _owner Address of token owner.
  /// @param _spender Address of token spender.
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}
