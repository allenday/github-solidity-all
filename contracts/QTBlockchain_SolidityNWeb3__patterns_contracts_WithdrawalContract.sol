pragma solidity ^0.4.4;

contract WithdrawalContract {

  struct Payer {
    address payer;
    uint    amount;
  }

  // Array of all payers
  Payer[]  payers;

  /**
   * Pay to this function
   * To make things easier - payer can pay only once, if tries more than once throw
   **/
  function  pay() payable {
    
    if(msg.value == 0) revert();

    payers.push( Payer(msg.sender, msg.value));
  }

  /**
   * Withdraw using this function
   **/
  function  withdraw() {
    // Check if there is a balance for the caller
    for(uint i=0; i < payers.length; i++){
      if(msg.sender == payers[i].payer){

        require(payers[i].amount > 0);

        uint amt = payers[i].amount;
        
        payers[i].amount = 0;

        // revert() if sender returns a false
        // otherwise the 
        assert(msg.sender.send(amt));

        return;
      }
    }
    // That means the address was not found in the list of payers
    revert();
  }

  function  getBalance() returns (uint){
    return this.balance;
  }

}
