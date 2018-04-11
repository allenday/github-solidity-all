/*
This Token Contract implements the Peculium token (beta)
.*/

import "./MintableToken.sol";

pragma solidity ^0.4.8;

contract Peculium is MintableToken {

    	/* Public variables of the token */
	string public name = "Peculium"; //token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;
	uint256 public NB_TOKEN = 20000000000; // number of token to create
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8; //NB_TOKEN*10** decimals;
	
	uint256 public START_PRE_ICO_TIMESTAMP   =1509494400; //start date of PRE_ICO 
        uint256 public START_ICO_TIMESTAMP=START_PRE_ICO_TIMESTAMP+ 10* 1 days ;
	uint256 public END_ICO_TIMESTAMP   =1514764800; //end date of ICO 
	uint256 public constant THREE_HOURS_TIMESTAMP=10800;// month in minutes  (1month =43200min) 
	uint256 public constant WEEK_TIMESTAMP=604800;
	uint256 public constant BONNUS_FIRST_THREE_HOURS_PRE_ICO = 35 ; // 35%
	uint256 public constant BONNUS_FIRST_TEN_DAYS_PRE_ICO = 30 ; // 35% 
	uint256 public constant BONNUS_FIRST_TWO_WEEKS_ICO  = 20 ;
	uint256 public constant BONNUS_AFTER_TWO_WEEKS_ICO  = 15 ; 
	uint256 public constant BONNUS_AFTER_FIVE_WEEKS_ICO = 10 ;
	uint256 public constant BONNUS_AFTER_SEVEN_WEEKS_ICO = 5 ; 
	uint256 public constant INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN = 25 ; 
	using SafeMath for uint256;
	uint256 public teamShare; //token for the dev team
	uint256 public bountyShare;
	uint256 public bountymanagerShare;
	uint256 public bountyFinal;
	uint256 public tokenAviableForIco; //token to be sold during the preICO and the ICO.
	uint256 public tokenAviableAfterIco;
	uint256 public dateOfPayment_TimeStamp;
	uint256 public Airdropsamount;
	uint256 public constant END_PAYMENTE_TIMESTAMP=1533074400;
	// Variable usefull for verifying that the assignedSupply matches that totalSupply 
	uint256 public assignedSupply;
	uint256 public beginICOdate; 	
	//Boolean to allow or not the initial assignement of token (batch) 
	bool public batchAssignStopped = false;	
	uint256 amount = MAX_SUPPLY_NBTOKEN;
	
	
	//Constructor
	function Peculium() {
		owner = msg.sender;
		tokenAviableForIco = amount * INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN/ 100;
		Airdropsamount = 50000000*10**8;
		teamShare=amount*12/100;
		bountyShare=amount*3/100-Airdropsamount;
		bountymanagerShare = 72000000*10**8; // we allocate 72 million token to the bounty manager
		bountyFinal= bountyShare - bountymanagerShare;
		dateOfPayment_TimeStamp=END_ICO_TIMESTAMP;
		tokenAviableAfterIco=amount-(tokenAviableForIco+teamShare+bountyShare);
                balances[owner]  = tokenAviableForIco;
                beginICOdate = now; // change for tests
	}


	function buyTokenPreIco(address toAddress, uint256 _vamounts) onlyOwner {
            require ( batchAssignStopped == false );
	    if (START_PRE_ICO_TIMESTAMP <=now && now <= (START_PRE_ICO_TIMESTAMP + THREE_HOURS_TIMESTAMP)){   
                 
                     
                     uint256 amountTo_Send = _vamounts*10**decimals *(1+BONNUS_FIRST_THREE_HOURS_PRE_ICO/100);
                     
                            balances[toAddress] += amountTo_Send;
                    
            }
	    if (START_PRE_ICO_TIMESTAMP+ THREE_HOURS_TIMESTAMP <=now && now <= (START_PRE_ICO_TIMESTAMP + 10* 1 days)){   
                 
                     
                      amountTo_Send = _vamounts*10**decimals *(1+BONNUS_FIRST_TEN_DAYS_PRE_ICO/100);
                     
                            balances[toAddress] += amountTo_Send;
                    
            }
	}

	
	function buyTokenIco(address toAddress, uint256 _vamounts) onlyOwner {
	         require ( batchAssignStopped == false );
		 if ((START_ICO_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 2*WEEK_TIMESTAMP) ){
                 
                     
			uint256 amountTo_Send = _vamounts* 10**decimals *(1+BONNUS_FIRST_TWO_WEEKS_ICO/100);
                     
                       
			balances[toAddress] += amountTo_Send;
                    
		}
		if ((START_ICO_TIMESTAMP+ 2*WEEK_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 5*WEEK_TIMESTAMP) ){
		
                     
			amountTo_Send = _vamounts*10**decimals *(1+BONNUS_AFTER_TWO_WEEKS_ICO/100);
                     
			balances[toAddress] += amountTo_Send;
                    
		}
		if ((START_ICO_TIMESTAMP+ 5*WEEK_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 7*WEEK_TIMESTAMP) ){
		
        
			amountTo_Send = _vamounts*10**decimals *(1+BONNUS_AFTER_FIVE_WEEKS_ICO/100);
                     
                       
			balances[toAddress] += amountTo_Send;
                    
		}
		if (START_ICO_TIMESTAMP+ 7*WEEK_TIMESTAMP< now){
		
                     	     amountTo_Send = _vamounts*10**decimals *(1+BONNUS_AFTER_SEVEN_WEEKS_ICO/100);
                     
                       
                            balances[toAddress] += amountTo_Send;
                    
		}
	
	}


	function buyTokenPostIco(address toAddress, uint256 _vamounts) onlyOwner {
		require ( batchAssignStopped == false );      
		uint256 amountTo_Send = _vamounts*10**decimals;
		balances[toAddress] += amountTo_Send;        
	}


	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner {
		require ( batchAssignStopped == false );
		require ( _vaddr.length == _vamounts.length );
		//Looping into input arrays to assign target amount to each given address 
		if(now == END_ICO_TIMESTAMP){
			for (uint index=0; index<_vaddr.length; index++) {
			address toAddress = _vaddr[index];
			uint amountTo_Send = _vamounts[index] * 10 ** decimals;
			balances[toAddress] += amountTo_Send;
                    
			}
			
		}
              
	}

	address bountymanager ; // public key of the bounty manager 
	
	function change_bounty_manager (address public_key) onlyOwner{ // to change the bounty manager
		bountymanager = public_key;
	}
	
	bool First_pay_bountymanager=true;
	uint256 first_pay = 40*bountymanagerShare/100;
	uint256 montly_pay = 10*bountymanagerShare/100;
	function payBounty() { // to pay the bountymanager
		
		if(msg.sender==bountymanager ){ 
			if((First_pay_bountymanager==true) && (now > END_ICO_TIMESTAMP)){ 
			balances[msg.sender] += first_pay; // The first payment is 40% of the total money due to the bounty manager
			bountymanagerShare -= first_pay;
			First_pay_bountymanager = false;
			uint256 pay_day = END_ICO_TIMESTAMP + 30;
			}
			else if( (First_pay_bountymanager==false) && (now > pay_day)){
			balances[msg.sender] += montly_pay; // Every month , the bounty manager receive 10% of the total money due to him.
			bountymanagerShare -= montly_pay;
			pay_day = pay_day + 30; // Can only be called once a month		
			
			}
		}
	
	
	}

 
	/* Approves and then calls the receiving contract */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);

		require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        	return true;
    }

	function teamPayment(address teamaddr) onlyOwner{
		if(now>dateOfPayment_TimeStamp && now< END_PAYMENTE_TIMESTAMP){
			uint256 wages=teamShare*10/100;
		    	if(dateOfPayment_TimeStamp<END_ICO_TIMESTAMP+ 30 * 1 days){
		     		wages=teamShare*40/100;
				dateOfPayment_TimeStamp+=30*1 days; //second payement two months from the first one.
		     	}
                     	balances[teamaddr]+=wages;
		     	dateOfPayment_TimeStamp+=30*1 days;

		}
	}
   

  	function getBlockTimestamp() constant returns (uint256){
        	return now;
  	}


	function stopBatchAssign() onlyOwner {
      		require ( batchAssignStopped == false);
      		batchAssignStopped = true;
	}

 
  	function balanceOf(address _owner) constant returns (uint256 balance) {
    		return balances[_owner];
	}


  	function getOwnerInfos() constant returns (address owneraddr, uint256 balance)  {
    		owneraddr= owner;
		balance = balances[owneraddr];
  	}


	function killContract() onlyOwner { // fonction to destruct the contract.
		selfdestruct(owner);
 	}
}
