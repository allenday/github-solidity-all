/*smart contract written in solidity, that will take an address, check the balance is greater than 1 Eth or not.
  if true, it will return true to this nodejs app */

  contract Authenticate{

  	address public userAddress;
  	var minimumBalance;

  	function Authenticate(address userAddress){

  		this.userAddress	=	userAddress;
  		/* 
  			* minimum balance should be 2 Eth for user to be authenticated. 
  			* the rates to be charged per the amount of waste produced is still to be determined at this point.
  			* 2 Ether is selected to accommodate the minimum amount of balance (charge of weight of waste produced + transaction cost in ethereum) 	 that is needed to make a waste deposite happen. 
  			* This will change later. 

  		*/
  		this.minimumBalance	=	2; 
  	}


  	// checks if the balance in user wallet is equal to more that or equal to the minimum balance required or not
  	function checkBalance(){

  		return (this.userAddress.balance > minimumBalance) ? true : false;

  	}


  }

