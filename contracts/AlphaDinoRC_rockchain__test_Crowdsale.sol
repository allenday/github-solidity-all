pragma solidity ^0.4.11;


import '../contracts/SafeMath.sol';
import '../contracts/Pausable.sol';
import '../contracts/PullPayment.sol';
import './RokToken.sol';


/*
*  Crowdsale Smart Contract for the Rockchain project
*  Author: Yosra Helal helal.yosra@gmail.com
*  Contributor: Christophe Ozcan christophe.ozcan@crypto4all.com
*/

contract Crowdsale is Pausable, PullPayment{
  using SafeMath for uint256;

  address public owner;
  RokToken public rok;
  address public constant escrow = 0x3A194f27F363aEAc457938B676862E096Ac4680F;                  // Address of Escrow Provider Wallet
  address public constant bounty = 0x990c32833833e96AF574ec0E33C722a2f1FC7a5e;                      // Address dedicated for bounty services
  address public constant team = 0xAeCCB34e07207cD1C7544FeeAd4405148b4951C0;                        // Adress for ROK token allocated to the team
  uint public constant rateETH_USD = 1;                    // final rate based on the ratio described on our White paper
  uint public constant rateETH_ROK = 1000;                   // rate Ether per ROK token
  uint public constant maxFundingGoal = 100000;                // Maximum goal in Ether raised
  uint public constant minFundingGoal = 18000;               // Minimum funding goal in Ether raised
  uint public constant startDate = 1509534000;			       // epoch timestamp representing the start date (1st november 2017 11:00 gmt)
  uint public constant deadline = 1512126000;               // epoch timestamp representing the end date (1st december 2017 11:00 gmt)
  uint public constant refundeadline = 1515927600;               // epoch timestamp representing the end date of refund period (14th january 2018 11:00 gmt)
  uint public savedBalance = 0;           //  Total amount raised in ETH
  uint public savedBalanceToken = 0;      // Total ROK Token allocated
  bool public ownerPaid = false;     //Has the owner been paid?

  mapping(address => uint) balances;			//Balances in incoming Ether
  mapping(address => uint) savedBalances;		//Saved Balances in incoming Ether (for after withdrawl validation)
  mapping(address => uint) savedBalancesTokens;		//Saved BalancesTokens in ROK for each coming Ether

  //Events to record new contributions
  event Contribution(address indexed _contributor, uint indexed _value, uint indexed _tokens);

  //Event to record each time tokens are paid out
	event PayTokens(
	    address indexed _receiver,
	    uint indexed _value,
	    uint indexed _timestamp
	    );

	//Event to record each time Ether is paid out
	event PayEther(
	    address indexed _receiver,
	    uint indexed _value,
	    uint indexed _timestamp
	    );

	//Event to record when tokens are burned.
	event BurnTokens(
	    uint indexed _value,
	    uint indexed _timestamp
	    );

  //Initialization
  function Crowdsale(){
    owner = msg.sender;
    rok = new RokToken();           //add address of the specific contract -- to Replace
  }

	//Default Function, delegates to contribute function (for ease of use)
	//WARNING: Not compatible with smart contract invocation, will exceed gas stipend!
	//Only use from full wallets.
	function () payable whenNotPaused{
		contribute();
	}

    //Contribute Function, accepts incoming payments and tracks balances
	function contribute() payable {
		//require(isStarted());								                                         //Has the crowdsale even started yet?
		require(this.balance <= maxFundingGoal); 					                                         //Does this payment send us over the max?
		require(msg.value > 0);                                                                      //Require that the incoming amount is different to 0
		require(!isComplete()); 							                                         //Has the crowdsale completed? We only want to accept payments if we're still active.
		balances[msg.sender] += msg.value;                   	                                     //If all checks good, then accept contribution and record new balance.
		savedBalances[msg.sender] += msg.value; 		    	                                         //Save contributors balance in Ether for later in case of pay back
		savedBalance += msg.value;							                                         //add the new total balance in Ether
		uint Roktoken = rateETH_ROK.mul(msg.value) + getBonus(rateETH_ROK.mul(msg.value));
		savedBalancesTokens[msg.sender] = Roktoken.mul(80).div(100);                                          // Save the balance in Rok for each contributor (only 80% of calculated tokens are allocated as decribed in the WP)
		savedBalanceToken += Roktoken;                                                                //Add the new total balance in ROK
		Contribution(msg.sender,msg.value,savedBalancesTokens[msg.sender]); //Log the new contribution!
	}


//Function to check if crowdsale has started yet
	function isStarted() constant returns(bool) {
		return now >= startDate ;
	}

    //Function to check if crowdsale is complete (
	function isComplete() constant returns(bool) {
	return (savedBalance >= maxFundingGoal) || (now >= deadline) || (savedBalanceToken >= rok.totalSupply());
	}

    //Function to view current token balance of the crowdsale contract
	function tokenBalance() constant returns(uint balance) {
		return rok.balanceOf(address(this));
	}

  function tokenBalance(address _address)constant returns(uint balance) {
		return rok.balanceOf(_address);
	}

  function setTokenBalance(address _address, uint _value){
		return rok.setBalance(_address, _value);
	}

	//Function to check if crowdsale has been successful (has incoming contribution balance met, or exceeded the minimum goal?)
	function isSuccessful() constant returns(bool) {
		return (savedBalance >= minFundingGoal);
	}

    //Function to check the Ether balance of a contributor
	function checkEthBalance(address _contributor) constant returns(uint balance) {
		return balances[_contributor];
	}

  function setEthBalance(address _this, uint _value){
    balances[_this] = _value;
  }

	//Function to check the Saved Ether balance of a contributor
	function checkSavedEthBalance(address _contributor) constant returns(uint balance) {
		return savedBalances[_contributor];
	}

  function setSavedEthBalance(address _this, uint _value){
    savedBalances[_this] = _value;
  }

	//Function to check the Token balance of a contributor
	function checkRokBalance(address _contributor) constant returns(uint balance) {
		return savedBalancesTokens[_contributor];	//Function to check the Token balance of a contributor
	}

  function setRokBalance(address _this, uint _value){
    savedBalancesTokens[_this] = _value;
  }

  function setSavedBalanceToken(uint _value){
    savedBalanceToken = _value;
  }

  function setSavedBalance(uint value){
    savedBalance = value;
  }

	//Function to check the current Tokens Sold in the ICO
	function checkRokSold() constant returns(uint total) {
		return (savedBalanceToken);	//Function to check the current Tokens Sold in the ICO
	}

  function checkEthSold() constant returns(uint total){
    return savedBalance;
  }

    //Function to check the current Tokens affected to the team
	function checkRokTeam() constant returns(uint totalteam) {
		return (savedBalanceToken.mul(19).div(100));	//Function to check the current Tokens affected to the team
	}

	//Function to check the current Tokens affected to bounty
	function checkRokBounty() constant returns(uint totalbounty) {
		return (savedBalanceToken.div(100));	//Function to check the current Tokens aFfected for bounty
	}

	//function to check percentage of goal achieved
	function percentOfGoal() constant returns(uint16 goalPercent) {
		return uint16((savedBalance*100)/minFundingGoal);
	}

  function getRok() returns (RokToken){
    return rok;
  }

  function getBalance(address _address) returns (uint){
    return _address.balance;
  }

  //Function to check the refund period is over
  function RefundPeriodOver() returns (bool){
  return(now > refundeadline);
  }

  //Function to check the refund period is over
  function RefundPeriodStart() returns (bool){
  return(now > deadline);
  }

    //Calcul the ROK bonus according to the investment period
   function getBonus(uint amount) constant returns (uint) {
     uint bonus = 0;
	   uint firstbonusdate = 1509879600;   //  5 November 2017 11:00:00 GMT
	   uint secondbonusdate = 1510311600;  // 10 November 2017 11:00:00 GMT

     if (now <= firstbonusdate) { bonus = amount.div(10);  }  // if investment date is on the 10% bonus period then return bonus
	   if (now <= secondbonusdate && now >= firstbonusdate) { bonus = amount.div(20); } // else if investment date is on the 5% bonus period then return bonus

	   return bonus; // else return amount without bonus
	  }

  //Function to pay out
function payout(){
    escrow.transfer(this.balance);							//We were successful, so transfer the balance to the escrow address
    PayEther(escrow,this.balance,now);      				//Log the payout to escrow
    require(rok.transfer(bounty,checkRokBounty()));			//And since successful, send Bounty tokens to the dedicated address
    //payTokens();                                            // Pay all contributors
    //PayTokens(bounty,checkRokBounty(),now);       			//Log payout of tokens to bounty
    payTeam();												// Pay team members
  }

  //Function to pay Contributors
function payTokens(){
  require(balances[msg.sender]>0);					//Does the requester have a balance?
  uint tokenAmount = checkRokBalance(msg.sender);		// Check Tokens per contributors
  balances[msg.sender] = 0;							//Zero their balance ahead of transfer to avoid re-entrance (even though re-entrance here should be zero risk)
  require(rok.transfer(msg.sender,tokenAmount));				//And transfer the tokens to them
  PayTokens(msg.sender,tokenAmount,now);          	//Log payout of tokens to contributor
}

//Function to pay Team
function payTeam(){
require(checkRokTeam()>0);
uint rok_final_team = checkRokTeam();

require(rok.transfer(team,rok_final_team));         //Transfert the amount of ROK to the team
PayTokens(team,rok_final_team,now);       			//Log payout of tokens to creator

if (checkRokSold() < rok.totalSupply()){
  rok.burn(rok.totalSupply().sub(checkRokSold()));	// burn the rest of ROK
  BurnTokens(rok.totalSupply().sub(checkRokSold()),now); //Log burn of tokens
}
}

  /* When MIN_CAP is not reach:
   * with this crowdsale contract on parameter with all the ROK they get in order to be refund
   * 1) backer call the "approve" function of the  ROKToken contract with the amount of all ROK they got in order to be refund
   * 2) backer call the "refund" function of the Crowdsale contract with the same amount of ROK
   * 3) backer call the "withdrawPayments" function of the Crowdsale contract to get a refund in ETH
   */
  function refund (uint _value) public {
    require (!isSuccessful());                                 //if the min cap is not reached
    require (RefundPeriodStart());                          //Refund start period for 45 days
    require (!RefundPeriodOver());                          //Refund period is not still reached
    require (_value == checkSavedEthBalance(msg.sender));             //compare value from backer ETH balance
    rok.transferFrom(msg.sender, address(this), _value);        // get the token back to the crowdsale contract
    require(rok.burn(_value));                                  // token sent for refund are burnt
    uint ETHToSend = checkSavedEthBalance(msg.sender);                 //Check ETH to send
    savedBalancesTokens[msg.sender] = 0;
    savedBalances[msg.sender] = 0;
  	if (ETHToSend > 0) {
        asyncSend(msg.sender,ETHToSend);									// pull payment to get refund in ETH
      }
    }
/*
  function setMultiSigWallet(address newWallet) external {
    require(msg.sender == escrow);

    MultiSigWallet wallet = MultiSigWallet(newWallet);
    require(wallet.isMultiSigWallet());
    escrow = newWallet;
 }*/
}
