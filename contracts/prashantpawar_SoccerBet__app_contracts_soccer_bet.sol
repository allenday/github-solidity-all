contract SoccerBet {
    enum Team { A, B }
    
    struct BettingParty {
        Team bettedTeam;
        uint amount;
        address account;
    }
    
    BettingParty A;
    BettingParty B;

    address oracle;
    uint spareAmount;
    
    function SoccerBet(address bettingPartyA, address bettingPartyB) {
        oracle = msg.sender;
        A.account = bettingPartyA;
        B.account = bettingPartyB;
        A.amount = 0;
        B.amount = 0;
        spareAmount = msg.value;
    }
    
    function depositFunds(Team t) {
        if (msg.sender == A.account) {
            //Is the caller betting party A
            A.amount += msg.value;
            A.bettedTeam = t;
        } else if (msg.sender == B.account) {
            //Or is the caller betting party B
            B.amount += msg.value;
            B.bettedTeam = t;
        } else {
            //Just in off chance someone sent some money to this account, 
            //lets store it and distribute it to the winner
            spareAmount += msg.value;
        }
     }
    
    /**
     * We are going to allow setting of the outcome as long as 
     * one party has deposited money. It is upon the Oracle to not 
     * set the outcome of the contract before both parties have 
     * gotten a chance to deposit money.
     * */
    function setOutcome(Team t, uint8 posession) {
        //We just need to calculate the losing party's earnings
        uint loserEarnings = 0;
        //Send money logic here
        //Winner gets money of the losing party * posession of winning side / 100
        if (A.bettedTeam == t) {
            loserEarnings = B.amount - (B.amount * posession/100); 
            B.account.send(loserEarnings);
            //Kill the contract, and send all the money to the winner, which is:
            //B.amount * (1 - posession)/100
            suicide(A.account);
        } else if (B.bettedTeam == t) {
            loserEarnings = A.amount - (A.amount * posession/100);
            A.account.send(loserEarnings);
            //Kill the contract, and send all the money to the winner, which is:
            //A.amount * (1 - posession)/100
            suicide(B.account);
        }
    }
}
