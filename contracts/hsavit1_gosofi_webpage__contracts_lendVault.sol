pragma solidity ^0.4.13; //We have to specify what version of the compiler this code will use
contract lendVault {
    // We use the struct datatype to store the borrower information.
    struct borrower {
        address borrowerAddress; // The address of the borrower
        uint tokensBorrowed;    // The total no. of tokens this voter borrowed
        uint tokensOwed;    // The total no. of tokens this voter borrowed
        bool initialized;
    }
    /* mapping is equivalent to an associate array or hash
   The key of the mapping is borrower address and the value is a borrower struct
   */
    mapping (address => borrower) public borrowersInfo;
    // public variables that keep track of the performance of this lending fund
    uint public tokenFund; // The total no. of tokens in the lending fund
    uint public fundLeft; // The total no. of tokens left in the fund
    uint public fundLent; // The total no. of tokens lent so far, historically
    uint public fundOwed; // Tht total no. of tokens still owed
    uint public fundPaid; // The total no. of tokens paid back
    uint public fundReturn; // The total amount of profit made by the fund

/* When the contract is deployed on the blockchain, we will initialize
   the total number of tokens in the fund & other variables
   move the funds from the lender address
   to the lendVault and make the funds available for lending
   */
  function lendVault() {
    tokenFund = 0; // set the tokenFund to the initial fundAmount
    fundLeft = 0; // set tokensLeft to initial fundAmount
    fundLent = 0;
    fundOwed = 0;
    fundPaid = 0;
    fundReturn = 0;
  }

    //contractInstance.fundVault({value: web3.toWei(fundAmount, ‘ether’), from: web3.eth.accounts[0]}
    //Funds must come in format of Wei!
    //
    function fundVault() payable {
        fundLeft += msg.value; // The total number of funds currently in the vault
        tokenFund += msg.value;
    }

		function() payable {
		}

    //contractInstance.borrowFunds(web3.toWei(fundsRequested), {from: web3.eth.accounts[0]}, getProperties);
    function borrowFunds(uint256 _fundsRequestedInWei) {
        // borrower storage currBorrower = borrowersInfo[msg.sender];
        // check if borrower already exists
        // if (!currBorrower.initialized) {
        //    borrowersInfo[msg.sender]; // create new borrower
        //    currBorrower = borrowersInfo[msg.sender];
        //    currBorrower.borrowerAddress = msg.sender;
        //    currBorrower.tokensBorrowed = 0;
        //    currBorrower.tokensOwed = 0;
        //    currBorrower.initialized = true;
        // }
        // currBorrower.tokensBorrowed += _fundsRequestedInWei;
        // currBorrower.tokensOwed += _fundsRequestedInWei;
        // if (_fundsRequestedInWei > 5) revert(); // is the amount requested available? Let’s set a limit here so someone doesn’t take all the funds
        msg.sender.transfer(_fundsRequestedInWei); // move _fundsRequestedInWei into borrowerAddress
        // borrowersInfo[msg.sender].tokensOwed += _fundsRequestedInWei; // increment total owed by this borrower
        // Update the contract state
        fundLeft -= _fundsRequestedInWei;
        fundOwed += _fundsRequestedInWei;
        fundLent += _fundsRequestedInWei;
    }

    /* This function is used to pay back the loan. Note the keyword ‘payable’
   below. By just adding that one keyword to a function, your contract can
   now accept Ether from anyone who calls this function. Accepting money can
   not get any easier than this!
   */
   //contractInstance.makePayment(web3.toWei(paymentAmount), {from: web3.eth.accounts[0]}, getProperties);
    function makePayment(uint256 _paymentInWei) payable {
        //uint payment = msg.value;
        //uint t_owed = borrowersInfo[msg.sender].tokensOwed; // get how much borrower owes
        //if (_payment > t_owed) revert(); // sending more money than is owed, does assert() return error with an error string?
        //borrowersInfo[msg.sender].tokensOwed -= _payment; // decrement total owed by this borrower
        fundLeft += _paymentInWei; // total no. of tokens left in the fund for lending
        fundOwed -= _paymentInWei; // total no. of tokens owed to the fund from all borrowers
        fundPaid += _paymentInWei; // total no of tokens paid back in the history of the contract
    }
    function getProperties() returns (uint[6]) {
        return [tokenFund,fundLeft,fundLent,fundOwed,fundPaid,fundReturn];
    }
}
