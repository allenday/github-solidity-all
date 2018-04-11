/*
This Token Contract implements the Peculium token (beta v2)
.*/


import "./PeculiumOld.sol";

pragma solidity ^0.4.15;


contract Peculium is BurnableToken,Ownable { // Our token is a standard ERC20 Token with burnable and ownable aptitude

	/*Variables about the old token contract */	
	PeculiumOld public peculOld; // The old Peculium token
	address public peculOldAdress = 0x53148Bb4551707edF51a1e8d7A93698d18931225; // The address of the old Peculium contract

	using SafeMath for uint256; // We use safemath to do basic math operation (+,-,*,/)
	using SafeERC20 for ERC20Basic; 

    	/* Public variables of the token for ERC20 compliance */
	string public name = "Peculium"; //token name 
    	string public symbol = "PCL"; // token symbol
    	uint256 public decimals = 8; // token number of decimal
    	
    	/* Public variables specific for Peculium */
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8; // The max cap is 20 Billion Peculium

	mapping(address => bool) public balancesCannotSell; // The boolean variable, to frost the tokens


    	/* Event for the freeze of account */
	event ChangedTokens(address changedTarget,uint256 amountToChanged);
	event FrozenFunds(address address_target, bool bool_canSell);

   
	//Constructor
	function Peculium() public {
		totalSupply = MAX_SUPPLY_NBTOKEN;
		balances[address(this)] = totalSupply; // At the beginning, the contract has all the tokens. 
		peculOld = PeculiumOld(peculOldAdress);	
	}
	
	/*** Public Functions of the contract ***/	
				
	function transfer(address _to, uint256 _value) public returns (bool) 
	{ // We overright the transfer function to allow freeze possibility
	
		require(balancesCannotSell[msg.sender]==false);
		return BasicToken.transfer(_to,_value);
	
	}
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
	{ // We overright the transferFrom function to allow freeze possibility
	
		require(balancesCannotSell[msg.sender]==false);	
		return StandardToken.transferFrom(_from,_to,_value);
	
	}

	/***  Owner Functions of the contract ***/	

   	function ChangeLicense(address target, bool canSell) public onlyOwner
   	{
        
        	balancesCannotSell[target] = canSell;
        	FrozenFunds(target, canSell);
    	
    	}
    	
    		function UpgradeTokens() public
	{
	// Use this function to swap your old peculium against new ones (the new ones don't need defrost to be transfered)
	// Old peculium are burned
		require(peculOld.totalSupply()>0);
		uint256 amountChanged = peculOld.allowance(msg.sender,address(this));
		require(amountChanged>0);
		peculOld.transferFrom(msg.sender,address(this),amountChanged);
		peculOld.burn(amountChanged);

		balances[address(this)] = balances[address(this)].sub(amountChanged);
    		balances[msg.sender] = balances[msg.sender].add(amountChanged);
		Transfer(address(this), msg.sender, amountChanged);
		ChangedTokens(msg.sender,amountChanged);
		
	}

	/*** Others Functions of the contract ***/	
	
	/* Approves and then calls the receiving contract */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);

		require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        	return true;
    }

  	function getBlockTimestamp() public constant returns (uint256)
  	{
        	return now;
  	}

  	function getOwnerInfos() public constant returns (address ownerAddr, uint256 ownerBalance)  
  	{ // Return info about the public address and balance of the account of the owner of the contract
    	
    		ownerAddr = owner;
		ownerBalance = balanceOf(ownerAddr);
  	
  	}

}
