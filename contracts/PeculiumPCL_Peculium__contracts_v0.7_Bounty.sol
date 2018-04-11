/*
This Token Contract pay the bounty holder and the airdrop
.*/
import "./StandardToken.sol";
import "./Ownable.sol";
pragma solidity ^0.4.8;

contract Bounty is StandardToken, Ownable  {
	uint256 public END_ICO_TIMESTAMP   =1514764800; //end date of ICO 
	uint256 public decimals = 8;
	using SafeMath for uint256;
	uint256 public bountyShare;
	uint256 public bountymanagerShare;
	uint256 public Airdropsamount;
	uint256 public bountyRemaining;

	//Constructor
	function Bounty(uint256 amount) {
		Airdropsamount = SafeMath.mul(50000000,(10**8));
		bountyShare=amount;
		bountymanagerShare = SafeMath.mul(72000000,(10**8)); // we allocate 72 million token to the bounty manager
		bountyRemaining = bountyShare.sub(bountymanagerShare.add(Airdropsamount));
	}
	address bountymanager ; // public key of the bounty manager 
	
	function change_bounty_manager (address public_key) onlyOwner{ // to change the bounty manager
		bountymanager = public_key;
	}
	
	bool First_pay_bountymanager=true;
	uint256 first_pay = SafeMath.div(SafeMath.mul(40,bountymanagerShare),100);
	uint256 montly_pay = SafeMath.div(SafeMath.mul(10,bountymanagerShare),100);

	function payBountyManager() { // to pay the bountymanager
		
		if(msg.sender==bountymanager ){ 
			if((First_pay_bountymanager==true) && (now > END_ICO_TIMESTAMP)){ 
			balances[msg.sender].add(first_pay); // The first payment is 40% of the total money due to the bounty manager
			bountymanagerShare.sub(first_pay);
			First_pay_bountymanager = false;
			uint256 pay_day = (END_ICO_TIMESTAMP).add(SafeMath.mul(30, 1 days));
			}
			else if( (First_pay_bountymanager==false) && (now > pay_day)){
			balances[msg.sender].add(montly_pay); // Every month , the bounty manager receive 10% of the total money due to him.
			bountymanagerShare.sub(montly_pay);
			pay_day = pay_day.add(SafeMath.mul(30,1 days)); // Can only be called once a month		
			
			}
		}
	
	
	}

	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner{
			require (Airdropsamount >0);
			require ( _vaddr.length == _vamounts.length );
			//Looping into input arrays to assign target amount to each given address 
			if(now == END_ICO_TIMESTAMP){
				for (uint256 index=0; index<_vaddr.length; index++) {
					address toAddress = _vaddr[index];
					uint256 amountTo_Send = _vamounts[index].mul(10 ** decimals);
				balances[toAddress].add(amountTo_Send);
				Airdropsamount.sub(amountTo_Send);
        	            
				}
				
			}
        	      
		}

	function payBounties(address[] _vaddr, uint256[] _vamounts) onlyOwner{
			require (bountyRemaining >0);
			require ( _vaddr.length == _vamounts.length );
			//Looping into input arrays to assign target amount to each given address 
			if(now == END_ICO_TIMESTAMP){
				for (uint256 index=0; index<_vaddr.length; index++) {
					address toAddress = _vaddr[index];
					uint256 amountTo_Send = _vamounts[index].mul(10 ** decimals);
				balances[toAddress].add(amountTo_Send);
				bountyRemaining.sub(amountTo_Send);
        	            
				}
				
			}
        	      
		}
 

}
