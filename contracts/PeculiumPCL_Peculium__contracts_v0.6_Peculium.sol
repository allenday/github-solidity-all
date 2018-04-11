/*
This Token Contract implements the Peculium token (beta)
.*/


import "./StandardToken.sol";
import "./Ownable.sol";
import "./Team.sol";
import "./Bounty.sol";
pragma solidity ^0.4.8;


contract Peculium is StandardToken,Ownable {

	using SafeMath for uint256;
    	/* Public variables of the token */
	string public name = "Peculium"; //token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8; 
	uint256 public constant START_PRE_ICO_TIMESTAMP   =1509494400; //start date of PRE_ICO 
        uint256 public constant START_ICO_TIMESTAMP=START_PRE_ICO_TIMESTAMP+ 10* 1 days ;
	uint256 public constant END_ICO_TIMESTAMP   =1514764800; //end date of ICO 
	uint256 public constant BONUS_FIRST_THREE_HOURS_PRE_ICO = 35 ; // 35%
	uint256 public constant BONUS_FIRST_TEN_DAYS_PRE_ICO = 30 ; // 35% 
	uint256 public constant BONUS_FIRST_TWO_WEEKS_ICO  = 20 ;
	uint256 public constant BONUS_AFTER_TWO_WEEKS_ICO  = 15 ; 
	uint256 public constant BONUS_AFTER_FIVE_WEEKS_ICO = 10 ;
	uint256 public constant BONUS_AFTER_SEVEN_WEEKS_ICO = 5 ; 
	uint256 public constant INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN = 25 ; 
	uint256 public rate;
	
	uint256 public Airdropsamount;
	//Boolean to allow or not the initial assignement of token (batch) 
	bool public assignStopped = false;	

	uint256 public tokenAvailableForIco;

	  event Finalized();
 	 bool public isFinalized = false;
	 Team teamContract;
	 Bounty bountyContract;

	//Constructor
	function Peculium() {

		rate = 30000; // 1 ether = 30000 Peculium
		totalSupply = MAX_SUPPLY_NBTOKEN;
		balances[owner] = totalSupply;
		tokenAvailableForIco = (totalSupply * INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN)/ 100;
		uint256 teamShare=totalSupply*12/100;
		uint256 bountyShare=totalSupply*3/100;
		teamContract=Team(teamShare);
		bountyContract=Bounty(bountyShare);


	}
		function receiveEtherFormOwner() payable onlyOwner {

	}
	function sendEtherToOwner() onlyOwner {
		uint256 moneyEther = (this.balance).div(1 ether);
		if(moneyEther > 0.01 ether){
		      owner.transfer(this.balance);
		      }
	}
	  // fallback function can be used to buy tokens
	function () payable {
	    buyTokens(msg.sender,msg.value);
	  }
	function buyTokens(address beneficiary, uint256 weiAmount)  payable AssignNotStopped NotEmpty 
	{
		require (START_PRE_ICO_TIMESTAMP <=now);
		require (msg.value > 0.1 ether);
		address toAddress = beneficiary;
                uint256 amountEther = weiAmount.div(1 ether);
                
		if(now <= (START_PRE_ICO_TIMESTAMP + 10 days))
		{
			buyTokenPreIco(toAddress,amountEther); 
		}

		if(START_ICO_TIMESTAMP <=now && now <= (START_ICO_TIMESTAMP + 8 weeks))
		{
			buyTokenIco(toAddress,amountEther);
		}
		if(now>(START_ICO_TIMESTAMP + 8 weeks))
		{
			buyTokenPostIco(toAddress,amountEther);
		}
	
	}
	
	function sendTokenUpdate(address toAddress, uint256 amountTo_Send) internal
	{
	                    balances[owner].sub(amountTo_Send);
                     	    totalSupply.sub(amountTo_Send);
                            balances[toAddress].add(amountTo_Send);
	
	}

	function buyTokenPreIco(address toAddress, uint256 _vamounts) payable AssignNotStopped NotEmpty ICO_Fund_NotEmpty{
	    require(START_PRE_ICO_TIMESTAMP <=now);
	    require(now <= (START_PRE_ICO_TIMESTAMP + 10 days));
	    if (START_PRE_ICO_TIMESTAMP <=now && now <= (START_PRE_ICO_TIMESTAMP + 3 hours)){   
                 

                     
                     uint256 amountTo_Send = _vamounts*rate*10**decimals *(1+(BONUS_FIRST_THREE_HOURS_PRE_ICO/100));
                     	tokenAvailableForIco.sub(amountTo_Send);	
			sendTokenUpdate(toAddress,amountTo_Send);
                    
            }
	    if (START_PRE_ICO_TIMESTAMP+ 3 hours <=now && now <= (START_PRE_ICO_TIMESTAMP + 10 days)){   
                 
                     
                      amountTo_Send = _vamounts*rate*10**decimals *(1+(BONUS_FIRST_TEN_DAYS_PRE_ICO/100));
                     	tokenAvailableForIco.sub(amountTo_Send);	
			sendTokenUpdate(toAddress,amountTo_Send);
                    
            }
	}

	
	function buyTokenIco(address toAddress, uint256 _vamounts) payable onlyOwner AssignNotStopped NotEmpty ICO_Fund_NotEmpty{
		 require(START_ICO_TIMESTAMP <=now);


		 if ((START_ICO_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 2 weeks) ){
                 
                     
			uint256 amountTo_Send = _vamounts*rate* 10**decimals *(1+(BONUS_FIRST_TWO_WEEKS_ICO/100));
                     
                     	tokenAvailableForIco.sub(amountTo_Send);	
			sendTokenUpdate(toAddress,amountTo_Send);
                    
		}
		if ((START_ICO_TIMESTAMP+ 2 weeks) < now && now <= (START_ICO_TIMESTAMP + 5 weeks) ){
		
                     
			amountTo_Send = _vamounts*rate*10**decimals *(1+(BONUS_AFTER_TWO_WEEKS_ICO/100));
                     	tokenAvailableForIco.sub(amountTo_Send);	
			sendTokenUpdate(toAddress,amountTo_Send);
                    
		}
		if ((START_ICO_TIMESTAMP+ 5 weeks) < now && now <= (START_ICO_TIMESTAMP + 7 weeks) ){
		
        
			amountTo_Send = _vamounts*rate*10**decimals *(1+(BONUS_AFTER_FIVE_WEEKS_ICO/100));
                     
                     	tokenAvailableForIco.sub(amountTo_Send);	
			sendTokenUpdate(toAddress,amountTo_Send);
                    
		}
		if (START_ICO_TIMESTAMP+ 7  weeks < now){
		
                     	     amountTo_Send = _vamounts*rate*10**decimals *(1+(BONUS_AFTER_SEVEN_WEEKS_ICO/100));
                     
                     	tokenAvailableForIco.sub(amountTo_Send);	
			sendTokenUpdate(toAddress,amountTo_Send);
                    
		}
	
	}


	function buyTokenPostIco(address toAddress, uint256 _vamounts) payable AssignNotStopped NotEmpty {
		uint256 amountTo_Send = _vamounts*rate*10**decimals;
			sendTokenUpdate(toAddress,amountTo_Send);
	}


	
	
	/* Approves and then calls the receiving contract */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);

		require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        	return true;
    }

	
   

  	function getBlockTimestamp() constant returns (uint256){
        	return now;
  	}
	//function for paying teams wages
	function teamPayment(address teamaddr) onlyOwner{
		teamContract.teamPayment(teamaddr);

	}
	//function for paying Bounty
	function payBountyManager() { 
		bountyContract.payBountyManager();
	}
	
	//function for paying Airdrops
 	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner NotEmpty{
			require ( assignStopped == false );
			require ( _vaddr.length == _vamounts.length );
			bountyContract.airdropsTokens( _vaddr,_vamounts);
	}
	//function for paying the rest of bounties
	function payBounties(address[] _vaddr, uint256[] _vamounts) onlyOwner NotEmpty{
			require ( assignStopped == false );
			require ( _vaddr.length == _vamounts.length );
			bountyContract.payBounties( _vaddr,_vamounts);
	}


	function stopAssign() onlyOwner {
      		require ( assignStopped == false);
      		assignStopped = true;
	}
	function restartAssign() onlyOwner {
      		require ( assignStopped == true);
      		assignStopped = false;
	}

    modifier AssignNotStopped {
        require (!assignStopped);
        _;
    }
        modifier NotEmpty {
        require (totalSupply>0);
        _;
    }
        modifier ICO_Fund_NotEmpty {
        require (tokenAvailableForIco> rate*10**decimals);
        _;
    }
    
  	function getOwnerInfos() constant returns (address ownerAddr, uint256 ownerBalance)  {
    		ownerAddr = owner;
		ownerBalance = balanceOf(ownerAddr);
  	}
	  function finalize() onlyOwner public {
	    require(!isFinalized);
	    require(assignStopped);

	    Finalized();

	    isFinalized = true;
	  }
   	 function getEtherBalance() constant onlyOwner returns (uint)  {
        return this.balance;
    }


	function killContract() onlyOwner { // function to destruct the contract.
		selfdestruct(owner);
 	}
}
