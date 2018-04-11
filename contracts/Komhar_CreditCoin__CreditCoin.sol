contract mortal { 
    function kill() { 
        suicide(msg.sender); 
        
    } }
    
    /**
     * A contract to maintain a ledger of credit and execute the credit return on
     * specified time stamps.
     * 
     * Plan to utilize a contract (ethrereum alarm clock?) to execute the return logic periodically (hourly?)
     * 
     */
contract CreditCoin is mortal{
    
    /*
    the struct holds a single instance of the credit line extended. the contract client has to 
    enter the rows into the mapping.
    */
    struct creditcoin {
        uint amount;
        address to;
        uint ts;
        address from;
    }
    /*
    mapping of the struct, is it possible to key it off the timestamp?
    */
    mapping (uint=> creditcoin) credits;
    uint index=0;
    
    /*
    execute this method to create a row in the credit ledger to be executed some time in furture.
    */
    function createCredit(uint amount, address to, uint ts){
        if ((ts - now) < 360000) throw;
        credits[index] = creditcoin(amount, to, ts, msg.sender);
        index++;
    }
    /*
    This method should be executed to return the credit coin back to the address or in other words - 
    destroy it
    */
    
   function runCredits(){
        for (uint i=0; i< index; i++){
            if ( now > credits[i].ts){
                delete credits[i];
                for (uint j= i; j< index; j++){
                    credits[j] = credits[j-1];
                }
            }
            index--;
        }
    }
    
    /*
    assist in the searchfor creating reports like:
        .1. who extes credit to me, how much does a single adress owe.
        .2 How many Credit coins does a certain address own?
    */
    function getCredit(address from, address to) returns (uint amount){
        
          for (uint i=0; i< index; i++){
              if (credits[i].from == from && credits[i].to == to){
                  amount = amount + credits[i].amount;
              }
          }
          return amount;
    }
    
    /*
    Return a row of the ledger - should be executed as a loop
    */
    
    function getCreditLedger(uint i) constant returns (uint amount, address to, uint ts, address from){
        amount = credits[i].amount;
        to = credits[i].to;
        from = credits[i].from;
        ts = credits[i].ts;
    } 
}
