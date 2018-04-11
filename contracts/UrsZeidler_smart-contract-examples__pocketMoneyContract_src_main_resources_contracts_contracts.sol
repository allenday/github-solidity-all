/*
* (c) Urs Zeidler 2017
*
*/
pragma solidity ^0.4.0;


/*
* A contract to manage pocket money for one recipient.
*/
contract PocketMoneyContract {

	address public owner;
	address public donator;
	address public recipient;
	uint public claimInterval;
	uint public lastClaimed;
	uint public amount2Claim;
	uint public currentAmount;
	// Start of user code PocketMoneyContract.attributes
	//TODO: implement
	// End of user code
	
	modifier onlyOwner
	{
	    if (msg.sender != owner) throw;
	    _;
	}
	
	modifier onlyRecipient
	{
	    if (!isInitalized() || msg.sender != recipient) throw;
	    _;
	}
	
	/*
	* Signaled when the pocket money is claimed.
	* 
	* _recipient -
	* time -
	* amount -
	* intervals -
	* succsess -
	*/
	event PocketMoneyClaimed(address _recipient,uint time,uint amount,uint intervals,bool succsess);
	
	/*
	* Signaled when pocked money is received.
	* 
	* _donator -
	* time -
	* amount -
	*/
	event PocketMoneyDonated(address _donator,uint time,uint amount);
	
	
	function PocketMoneyContract() public   {
		//Start of user code PocketMoneyContract.constructor.PocketMoneyContract
		owner = msg.sender;
		//End of user code
	}
	
	
	/*
	* Receives the money for the past intervals.
	*/
	function claimPocketMoney() public  onlyRecipient()  {
		//Start of user code PocketMoneyContract.function.claimPocketMoney
		uint interval = (now - lastClaimed)/claimInterval;
		uint amount = amount2Claim * interval;
		
		if(amount>currentAmount || amount==0) throw;
		
		currentAmount-=amount;
		lastClaimed = now;
		bool succsess = recipient.send(amount);
		PocketMoneyClaimed(msg.sender,now,amount,interval,succsess);
		
		//End of user code
	}
	
	
	
	function isInitalized() private   constant returns (bool ) {
		//Start of user code PocketMoneyContract.function.isInitalized
		return amount2Claim!=0 && donator!=0 && claimInterval!=0 && recipient!=0;
		//End of user code
	}
	
	
	
	function () public  payable  {
		//Start of user code PocketMoneyContract.function.
		if(msg.sender!=donator) throw;
		
		if(lastClaimed==0) lastClaimed = now;
		
		currentAmount+=msg.value;
		PocketMoneyDonated(msg.sender,now,msg.value);
		//End of user code
	}
	
	// setOwner setter for the field owner
	function setOwner (address aOwner) onlyOwner() {
		owner = aOwner;
	}
	
	// setDonator setter for the field donator
	function setDonator (address aDonator) onlyOwner() {
		donator = aDonator;
	}
	
	// setRecipient setter for the field recipient
	function setRecipient (address aRecipient) onlyOwner() {
		recipient = aRecipient;
	}
	
	// setClaimInterval setter for the field claimInterval
	function setClaimInterval (uint aClaimInterval) onlyOwner() {
		claimInterval = aClaimInterval;
	}
	
	// setAmount2Claim setter for the field amount2Claim
	function setAmount2Claim (uint aAmount2Claim) onlyOwner() {
		amount2Claim = aAmount2Claim;
	}
	
	// Start of user code PocketMoneyContract.operations
	//TODO: implement
	// End of user code
}

