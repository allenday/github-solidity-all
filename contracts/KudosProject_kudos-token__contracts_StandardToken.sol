pragma solidity ^0.4.15;

import "./SafeMath.sol";
import "./ERC20Token.sol";

/**
 * @title ERC20 implementation
 *
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 * @dev Based on code by OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity
 */
contract StandardToken is ERC20Token {
   using SafeMath for uint256;

   mapping (address => uint256) balances;
   mapping (address => mapping (address => uint256)) allowed;

   /**
    * @dev gets the balance of the specified address
    * @param _owner The address to query the balance of
    * @return uint256 The balance of the passed address
    */
   function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
   }

   /**
    * @dev transfer tokens to the specified address
    * @param _to The address to transfer to
    * @param _value The amount to be transferred
    * @return bool A successful transfer returns true
    */
   function transfer(address _to, uint256 _value) returns (bool success) {
      require(_to != address(0));

      // SafeMath.sub will throw if there is not enough balance.
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
   }

   /**
    * @dev transfer tokens from one address to another
    * @param _from address The address that you want to send tokens from
    * @param _to address The address that you want to transfer to
    * @param _value uint256 The amount to be transferred
    * @return bool A successful transfer returns true
    */
   function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      require(_to != address(0));

      uint256 _allowance = allowed[_from][msg.sender];
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = _allowance.sub(_value);
      Transfer(_from, _to, _value);
      return true;
   }

   /**
    * @dev approve the passed address to spend the specified amount of tokens
    * @dev Note that the approved value must first be set to zero in order for it to be changed
    * @dev https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address that will spend the funds
    * @param _value The amount of tokens to be spent
    * @return bool A successful approval returns true
    */
   function approve(address _spender, uint256 _value) returns (bool success) {

     //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     require((_value == 0) || (allowed[msg.sender][_spender] == 0));

     allowed[msg.sender][_spender] = _value;
     Approval(msg.sender, _spender, _value);
     return true;
   }

   /**
    * @dev gets the amount of tokens that an owner has allowed an address to spend
    * @param _owner The address that owns the funds
    * @param _spender The address that will spend the funds
    * @return uint256 The amount that is available to spend
    */
   function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
     return allowed[_owner][_spender];
   }
}
