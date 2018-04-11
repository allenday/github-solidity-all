pragma solidity ^0.4.18;

import './ERC20.sol';
import './SafeMath.sol';


/// @title Standard ERC20 token
/// @dev Implementation of the basic standard token.
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  // PUBLIC FUNCTIONS

  /// @dev Transfers tokens to a specified address.
  /// @param _to The address which you want to transfer to.
  /// @param _value The amount of tokens to be transferred.
  /// @return A boolean that indicates if the operation was successful.
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /// @dev Transfers tokens from one address to another.
  /// @param _from The address which you want to send tokens from.
  /// @param _to The address which you want to transfer to.
  /// @param _value The amount of tokens to be transferred.
  /// @return A boolean that indicates if the operation was successful.
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowances[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /// @dev Approves the specified address to spend the specified amount of tokens on behalf of msg.sender.
  /// Beware that changing an allowance with this method brings the risk that someone may use both the old
  /// and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  /// race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  /// @param _spender The address which will spend tokens.
  /// @param _value The amount of tokens to be spent.
  /// @return A boolean that indicates if the operation was successful.
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowances[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Gets the balance of the specified address.
  /// @param _owner The address to query the balance of.
  /// @return An uint256 representing the amount owned by the specified address.
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  /// @dev Function to check the amount of tokens that an owner allowances to a spender.
  /// @param _owner The address which owns tokens.
  /// @param _spender The address which will spend tokens.
  /// @return A uint256 specifying the amount of tokens still available for the spender.
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowances[_owner][_spender];
  }

  // FIELDS

  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowances;
}
