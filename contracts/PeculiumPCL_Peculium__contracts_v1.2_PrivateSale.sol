/*
Contract for the privateSale of the Peculium campaign

Need to add :
- database access
- end of crowdsale : if goal not raised, refund people
- more security , and tests

*/

import "./Peculium.sol";
import "./RefundVault.sol";



pragma solidity ^0.4.15;


contract PrivateSale is Ownable{
	using SafeMath for uint256;
	
	uint256 public PrivateSalesAmount; // Airdrop total amount
	uint256 public decimals; // decimal of the token
	
	Peculium public pecul; // token Peculium
	bool public initPecul; // We need first to init the Peculium Token address


 	// minimum amount of funds to be raised in weis
	uint256 public goal;

	mapping (address => uint256) PrivateSaleEthers; // for now I use a mapping, will be changed with database access
	
	uint256 rate; // 1 ether = 25 000 PCL, maybe to change
	
	// start and end timestamps where investments are allowed (both inclusive)
 	uint256 public startTime;
  	uint256 public endTime;

	  // address where funds are collected
	  address public wallet;
 	 // amount of raised money in wei
  	uint256 public weiRaised;
	
	// refund vault used to hold funds while crowdsale is running
  	RefundVault public vault;

  	bool public isFinalized = false;
	event Finalized();

  	
  	event PrivateSalesSale(address receiverToken,uint256 nbTokenSend);
	
	event InitializedToken(address contractToken);
	//Constructor
	function PrivateSale(){
		rate = 25000;
		PrivateSalesAmount = 1000000000; // We allocate 1 Billion token for the privatesale (maybe to change) 
		initPecul = false;
		
		startTime = now; // to change
    		endTime = startTime + 10 days; //investors have 10 days to confirm their transactions
    		wallet = owner;
    		
    		goal = 300000 ether;
		
		vault = new RefundVault(wallet);


	}
	
	
	/***  Functions of the contract ***/
	
	
	function InitPeculiumAdress(address peculAdress) onlyOwner
	{ // We init the Peculium token address
	
		pecul = Peculium(peculAdress);
		decimals = pecul.decimals();
		initPecul = true;
		InitializedToken(peculAdress);
	}
	
	function() payable {
	
		buyTokens(msg.sender);
	
	}
	
	function buyTokens(address beneficiary) payable NotEmpty Initialize SaleNotStopped{ // do we need to make it internal or not ?
	    	require(beneficiary != address(0));
    		require(now >= startTime && now <= endTime);
    		require(msg.value != 0); // In fact more, to determine


		require(PrivateSaleEthers[msg.sender]>0);
		require(msg.value <= PrivateSaleEthers[msg.sender]); // to replace with database access
		
		uint256 tokenToSend = (msg.value).mul(rate);
		
		require(tokenToSend <= PrivateSalesAmount); 
		weiRaised = weiRaised.add(msg.value);

		pecul.transfer(msg.sender,tokenToSend*10**decimals);
		PrivateSaleEthers[msg.sender] = PrivateSaleEthers[msg.sender].sub(msg.value); 
		PrivateSalesAmount = PrivateSalesAmount.sub(tokenToSend);
		PrivateSalesSale(msg.sender,tokenToSend);
		
		forwardFunds();

	}
	  function forwardFunds() internal {
    		vault.deposit.value(msg.value*9/10)(msg.sender);
    		wallet.transfer(msg.value/10);
  		}


	  // if crowdsale is unsuccessful, investors can claim refunds here
	  function claimRefund() public {
	    require(isFinalized);
	    require(!goalReached());

	    vault.refund(msg.sender);
	  }
	



	  function goalReached() public constant returns (bool) {
    	return (weiRaised / 1 ether) >= goal;
  	}

		  function finalize() onlyOwner public {
	    require(!isFinalized);
	    require(now > endTime);

	    finalization();
	    Finalized();

	    isFinalized = true;
	  }

  // vault finalization task, called when owner calls finalize()

	  function finalization() internal {
	  
	    if (goalReached()) {
	      vault.close();
	    } else {
	      vault.enableRefunds();
	    }

	  }

	
	
	/***  Modifiers of the contract ***/

	modifier NotEmpty {
		require (PrivateSalesAmount>0);
		_;
	}
	
	modifier Initialize {
	require (initPecul==true);
	_;
	} 
	
	modifier SaleNotStopped {
        require (!isFinalized);
        _;
    	}
    	
    	
    
  }











	  
	  
	  
	

