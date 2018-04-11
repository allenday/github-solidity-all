pragma solidity ^0.4.15;

import './interfaces/ERC20Interface.sol';
import './utils/SafeMath.sol';

/**
 * @title Token
 * @dev Contract that implements ERC20 token standard
 * Is deployed by `Crowdsale.sol`, keeps track of balances, etc.
 */

 contract Token is ERC20Interface {

 	string public constant name = "BAB";
    string public constant symbol = "BAB";
    uint8 public constant decimals = 18;  // 18 is the most common number of decimal places

   	address owner;

   	uint256 public totalSupply;

   	mapping(address => uint256) balances;
   	mapping(address => mapping(address => uint256)) approved;

   	using SafeMath for uint256;

   	modifier isVerifiedBuyer() {
     		require(msg.sender != owner);
       	_;
     }

   	function Token(uint256 _totalSupply, address buyerAddress) public {
   		// address buyerAddress;
   		// address senderAddres;

       	balances[buyerAddress] = _totalSupply;
     	totalSupply = _totalSupply;
     	// queue.enqueue(buyerAddress);
     }

   	function addSupply(address buyerAddress, uint256 _amount) isVerifiedBuyer() public {
       	totalSupply += _amount;
       	balances[buyerAddress] = balances[buyerAddress].add(_amount); 
     }

     function burnToken(uint256 _amount) isVerifiedBuyer() public {
       if (balances[msg.sender] >= _amount) {
         totalSupply -= _amount;
         balances[msg.sender] = balances[msg.sender].sub(_amount);
       }
     }

 		/* @param _owner The address from which the balance will be retrieved
       @return The balance */
     function balanceOf(address _owner) constant public returns (uint256 balance) {
     		return balances[_owner];
     }

   	/* @notice send `_value` token to `_to` from `msg.sender`
       @param _to The address of the recipient
       @param _value The amount of token to be transferred
       @return Whether the transfer was successful or not */
     function transfer(address _to, uint256 _value) public returns (bool success) {
       	if (balances[msg.sender] < _value) {
         		return false;
         }
         balances[msg.sender] = balances[msg.sender].sub(_value);
       	balances[_to] = balances[_to].add(_value);
       	Transfer(msg.sender, _to, _value);
       	return true;
     }

   	  /* @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
         @param _from The address of the sender
         @param _to The address of the recipient
         @param _value The amount of token to be transferred
         @return Whether the transfer was successful or not */
     function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       	uint256 allowed = approved[_from][msg.sender];

       	if (balances[_from] < _value || allowed < _value) {
           	return false;
         }
       	balances[_from] = balances[_from].sub(_value);
       	approved[_from][msg.sender] = allowed.sub(_value);
  				balances[_to] = balances[_to].add(_value);
       	Transfer(_from, _to, _value);
       	return true;
     }

     /*@notice `msg.sender` approves `_spender` to spend `_value` tokens
       @param _spender The address of the account able to transfer the tokens
       @param _value The amount of tokens to be approved for transfer
       @return Whether the approval was successful or not */
     function approve(address _spender, uint256 _value) public returns (bool success) {
       	approved[msg.sender][_spender] = _value;
       	Approval(msg.sender, _spender, _value);
       	return true;
     }

   	function refundApprove(address _refundee, uint256 _value)  isVerifiedBuyer() public returns (bool success) {
       	approved[_refundee][msg.sender] = _value;
       	Approval(_refundee, msg.sender, _value);
       	return true;
     }

    /*@param _owner The address of the account owning tokens
      @param _spender The address of the account able to transfer the tokens
      @return Amount of remaining tokens allowed to spent */
     function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
       	return approved[_owner][_spender];
     }

     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 }
