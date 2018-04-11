/*
This Token Contract implements the Peculium token (beta)
.*/
import "./StandardToken.sol";
import "./Ownable.sol";
pragma solidity ^0.4.8;

contract Bounty is StandardToken, Ownable  {
	uint256 public END_ICO_TIMESTAMP   =1514764800; //end date of ICO 
	uint256 public decimals = 8;
	using SafeMath for uint256;
	uint256 public teamShare; //token for the dev team
	uint256 public bountyShare;
	uint256 public bountymanagerShare;
	uint256 public Airdropsamount;
	uint256 public bountyRemaining;

	//Constructor
	function Bounty(uint256 amount) {
		Airdropsamount = 50000000*10**8;
		bountyShare=amount;
		bountymanagerShare = 72000000*10**8; // we allocate 72 million token to the bounty manager
		bountyRemaining= bountyShare - (bountymanagerShare+Airdropsamount);
	}
	address bountymanager ; // public key of the bounty manager 
	
	function change_bounty_manager (address public_key) onlyOwner{ // to change the bounty manager
		bountymanager = public_key;
	}
	
	bool First_pay_bountymanager=true;
	uint256 first_pay = 40*bountymanagerShare/100;
	uint256 montly_pay = 10*bountymanagerShare/100;

	function payBountyManager() { // to pay the bountymanager
		
		if(msg.sender==bountymanager ){ 
			if((First_pay_bountymanager==true) && (now > END_ICO_TIMESTAMP)){ 
			balances[msg.sender] += first_pay; // The first payment is 40% of the total money due to the bounty manager
			bountymanagerShare -= first_pay;
			First_pay_bountymanager = false;
			uint256 pay_day = END_ICO_TIMESTAMP + 30 * 1 days;
			}
			else if( (First_pay_bountymanager==false) && (now > pay_day)){
			balances[msg.sender] += montly_pay; // Every month , the bounty manager receive 10% of the total money due to him.
			bountymanagerShare -= montly_pay;
			pay_day = pay_day + 30 * 1 days; // Can only be called once a month		
			
			}
		}
	
	
	}

	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner{
			require (Airdropsamount >0);
			require ( _vaddr.length == _vamounts.length );
			//Looping into input arrays to assign target amount to each given address 
			if(now == END_ICO_TIMESTAMP){
				for (uint index=0; index<_vaddr.length; index++) {
					address toAddress = _vaddr[index];
					uint amountTo_Send = _vamounts[index] * 10 ** decimals;
				balances[toAddress].add(amountTo_Send);
				Airdropsamount-=amountTo_Send;
        	            
				}
				
			}
        	      
		}

	function payBounties(address[] _vaddr, uint256[] _vamounts) onlyOwner{
			require (bountyRemaining >0);
			require ( _vaddr.length == _vamounts.length );
			//Looping into input arrays to assign target amount to each given address 
			if(now == END_ICO_TIMESTAMP){
				for (uint index=0; index<_vaddr.length; index++) {
					address toAddress = _vaddr[index];
					uint amountTo_Send = _vamounts[index] * 10 ** decimals;
				balances[toAddress].add(amountTo_Send);
				bountyRemaining-=amountTo_Send;
        	            
				}
				
			}
        	      
		}
 

}
