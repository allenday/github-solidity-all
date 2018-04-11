/*
This Token Contract implements the Peculium token (beta)
.*/


import "./BurnableToken.sol";
import "./Ownable.sol";

import "./SafeERC20.sol";

pragma solidity ^0.4.15;


contract PeculiumOld is BurnableToken,Ownable { // Our token is a standard ERC20 Token with burnable and ownable aptitude

	using SafeMath for uint256; // We use safemath to do basic math operation (+,-,*,/)
	using SafeERC20 for ERC20Basic; 

    	/* Public variables of the token for ERC20 compliance */
	string public name = "Peculium"; //token name 
    	string public symbol = "PCL"; // token symbol
    	uint256 public decimals = 8; // token number of decimal
    	
    	/* Public variables specific for Peculium */
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8; // The max cap is 20 Billion Peculium

	uint256 public dateStartContract; // The date of the deployment of the token
	mapping(address => bool) public balancesCanSell; // The boolean variable, to frost the tokens
	uint256 public dateDefrost; // The date when the owners of token can defrost their tokens


    	/* Event for the freeze of account */
 	event FrozenFunds(address target, bool frozen);     	 
     	event Defroze(address msgAdd, bool freeze);
	


   
	//Constructor
	function PeculiumOld() {
		totalSupply = MAX_SUPPLY_NBTOKEN;
		balances[owner] = totalSupply; // At the beginning, the owner has all the tokens. 
		balancesCanSell[owner] = true; // The owner need to sell token for the private sale and for the preICO, ICO.
		
		dateStartContract=now;
		dateDefrost = dateStartContract + 85 days; // everybody can defrost his own token after the 25 january 2018 (85 days after 1 November)

	}

	/*** Public Functions of the contract ***/	
	
	function defrostToken() public 
	{ // Function to defrost your own token, after the date of the defrost
	
		require(now>dateDefrost);
		balancesCanSell[msg.sender]=true;
		Defroze(msg.sender,true);
	}
				
	function transfer(address _to, uint256 _value) public returns (bool) 
	{ // We overright the transfer function to allow freeze possibility
	
		require(balancesCanSell[msg.sender]);
		return BasicToken.transfer(_to,_value);
	
	}
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
	{ // We overright the transferFrom function to allow freeze possibility (need to allow before)
	
		require(balancesCanSell[msg.sender]);	
		return StandardToken.transferFrom(_from,_to,_value);
	
	}

	/***  Owner Functions of the contract ***/	

   	function freezeAccount(address target, bool canSell) onlyOwner 
   	{
        
        	balancesCanSell[target] = canSell;
        	FrozenFunds(target, canSell);
    	
    	}


	/*** Others Functions of the contract ***/	
	
	/* Approves and then calls the receiving contract */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);

		require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        	return true;
    }

  	function getBlockTimestamp() constant returns (uint256)
  	{
        
        	return now;
  	
  	}

  	function getOwnerInfos() constant returns (address ownerAddr, uint256 ownerBalance)  
  	{ // Return info about the public address and balance of the account of the owner of the contract
    	
    		ownerAddr = owner;
		ownerBalance = balanceOf(ownerAddr);
  	
  	}

}
