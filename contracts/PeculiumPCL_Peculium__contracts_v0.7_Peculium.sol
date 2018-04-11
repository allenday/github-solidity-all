/*
This Token Contract implements the Peculium token (beta)
.*/


import "./BurnableToken.sol";
import "./Ownable.sol";
import "./Stakeholder.sol";
import "./Bounty.sol";

import "./SafeERC20.sol";

pragma solidity ^0.4.8;


contract Peculium is BurnableToken,Ownable {

	using SafeMath for uint256;
	using SafeERC20 for ERC20Basic;

    	/* Public variables of the token */
	string public name = "Peculium"; //token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8; 
	uint256 public constant START_PRE_ICO_TIMESTAMP   =1509494400; //start date of PRE_ICO 
        uint256 public constant START_ICO_TIMESTAMP= START_PRE_ICO_TIMESTAMP + ( 10 * 1 days) ;
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
	uint256 public amount;
	uint256 public reserveToken;
	uint256 public stakeholderShare;
	uint256 public bountyShare;
	//Boolean to allow or not the sale of tokens
	bool public sales_stopped = false;	
	bool public isFinalized = false;
	
	uint256 public tokenAvailableForIco;

	  event NewRate(uint256 rateUpdate);
	  event Finalized();
	  event Stopsale();
	  event Restartsale();
	  event Finalized();
 	 
 	 
	 Stakeholder StakeholderContract;
	 Bounty bountyContract;
	 
	
	
	//Constructor
	function Peculium() {

		rate = 30000; // 1 ether = 30000 Peculium
		totalSupply = MAX_SUPPLY_NBTOKEN;
		amount = totalSupply;
		balances[owner] = amount;
		tokenAvailableForIco = (amount.mul(INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN)).div(100);
		stakeholderShare=(amount.mul(12)).div(100);
		bountyShare=(amount.mul(3)).div(100);
		reserveToken = (amount.mul(60)).div(100);
		
		StakeholderContract=Stakeholder(stakeholderShare);
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
	function buyTokens(address beneficiary, uint256 weiAmount)  payable SaleNotStopped NotEmpty 
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
		
		// need function to buy token after ICO ? ?
	
	}
	
	function sendTokenUpdate(address toAddress, uint256 amountTo_Send) internal
	{
	                    amount.sub(amountTo_Send);
	                    transfer(toAddress,amountTo_Send);
	
	}

	function buyTokenPreIco(address toAddress, uint256 _vamounts) payable SaleNotStopped NotEmpty ICO_Fund_NotEmpty{
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

	
	function buyTokenIco(address toAddress, uint256 _vamounts) payable onlyOwner SaleNotStopped NotEmpty ICO_Fund_NotEmpty{
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

	function updateReserveToken() onlyOwner{
		require(now>END_ICO_TIMESTAMP);
		reserveToken.add(tokenAvailableForIco);
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
	//function for paying stakeholders wages
	function stakeholderPayment(address stakeholderaddr) onlyOwner{
		StakeholderContract.stakeholderPayment(stakeholderaddr);

	}
	//function for paying Bounty
	function payBountyManager() { 
		bountyContract.payBountyManager();
	}
	
	//function for paying Airdrops
 	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner NotEmpty{
			require ( sales_stopped == false );
			require ( _vaddr.length == _vamounts.length );
			bountyContract.airdropsTokens( _vaddr,_vamounts);
	}
	//function for paying the rest of bounties
	function payBounties(address[] _vaddr, uint256[] _vamounts) onlyOwner NotEmpty{
			require ( sales_stopped == false );
			require ( _vaddr.length == _vamounts.length );
			bountyContract.payBounties( _vaddr,_vamounts);
	}


	function stopSale() onlyOwner public{
      		require ( sales_stopped == false);
      		sales_stopped = true;
      		Stopsale();
	}
	function restartSale() onlyOwner public{
      		require ( sales_stopped == true);
      		sales_stopped = false;
      		Restartsale();
	}
	
	function changeRage(uint256 newrate) onlyOwner public{
		rate = newrate;
		NewRate(rate);
	}

    modifier SaleNotStopped {
        require (!sales_stopped);
        _;
    }
        modifier NotEmpty {
        require (amount>0);
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
	    require(sales_stopped);

	    Finalized();

	    isFinalized = true;
	  }
   	 function getEtherBalance() constant onlyOwner returns (uint256 balanceQuantity)  {
        balanceQuantity = this.balance;
    }


	function destroy() onlyOwner { // function to destruct the contract.
		selfdestruct(owner);
 	}
 	function destroyAndSend(address _recipient) onlyOwner public {
    		selfdestruct(_recipient);
	}

}
