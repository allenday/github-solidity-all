pragma solidity ^0.4.11;

import "../basic/owned.sol";

//================= Interface for CAP database contract =======================
contract iTokenCAP is owned
{
	function activeTokens() constant returns(uint amount);		// ammount of tokens on balances
	function mintedTokens() constant returns(uint amount);		// ammount of tokens created
	function burnedTokens() constant returns(uint amount);		// ammount of tokens destroyed
	function irreducibleOf(address _adr) constant returns(uint balance);	// irreducible remainder for account

	event Minted(address indexed _to, uint _value);		// Tokens minted
	event Burned(uint _value);							// Tokens burned
	event Limited(address indexed _acc, uint _limit);	// Irreducible remainder changed

	// Minting new tokens
	function mint(address _to, uint _amount) returns(bool success);

	// Set irreducible remainder for account
	function limitAccount(address _acc, uint _limit) returns(bool success);

	// Burn _amount of tokens that were not yet distributed
	function burnNotDistrTokens(uint _amount) returns(bool success);

	// Burn balance for specific account - can be used for migrations
	function burnBalance(address _account) returns(uint value);
}