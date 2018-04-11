pragma solidity ^0.4.11;

/// This is so we can set the price in USD constants
contract USDOracle {
    function WEI() constant returns (uint);
    function USD() constant returns (uint);
}
contract Lottery{
    
    address private owner;
    address[] participants;
    uint[] numbersGuessed;
    uint creationTime = now;
    uint jackPot = 0;
    uint charityFee;
    
    USDOracle oracle = USDOracle(0x1c68f4f35ac5239650333d291e6ce7f841149937);
    uint constant USD_IN_CENTS = 100;
    
    function Lottery () {
        owner = msg.sender;
    }
    
    modifier ifOwner {
        if (msg.sender != owner)
            throw;
        _;
    }
    
    modifier endPlay {
        if (creationTime + now == 7 days){
            _;
        }
        throw;
    }

    event Log(string message, address caller);

    function currentRate() constant returns (uint ratePerDollar) {
        ratePerDollar = USD_IN_CENTS * oracle.WEI();
        return ratePerDollar;
    }
    
    function currentJackPot() constant returns (uint jackPot) {
        return jackPot;
    }
    
    function buyTicket (uint _numberGuessed) payable {
        
        
        //if (msg.value != USD_IN_CENTS * oracle.WEI()) throw;
        if ( msg.value != 1 ether ) throw;
        
        jackPot += msg.value;
        participants.push(msg.sender);
        numbersGuessed.push(_numberGuessed);
        
        Log("You have entered in to the lottery", msg.sender);
        
    }
    
    //function getTicket () constant returns (string, string, uint) {
        //var entry = entries[msg.sender];
       // return (entry.firstName, entry.lastName, entry.numberGuessed);
    //}
    
    /// Pick a winner for small lotteries put winnings in entry's address
    function pickSmallWinner () ifOwner endPlay payable {
        //Oracilize a "random" number
        uint numPlayers = participants.length;
        if (numPlayers < 100){
            // pick the winner
            uint randomNum = 0;
            uint winner = randomNum % numPlayers; // Gets the index of the winner
            
            // subtract 2% charity fee from jackPot
            charityFee = (jackPot * 2) / 100;
            jackPot -= charityFee;
            participants[winner].transfer(jackPot);
            
        }
        
    }
    
    /// Pick a winner for a big lottery (over 100 participants) put earnings into winners address
    function pickBigWinner () ifOwner endPlay payable {
        // Oraclize a "random" number
        uint randomNum = 0; //change this to the random function
        // For small lotteries, we will just pick a random player
        uint numPlayers = participants.length;
        
        if (numPlayers > 100){
            // pick the winner
            // check for match
            for (uint i = 0; i < numPlayers; i++) {
                if (numbersGuessed[i] == randomNum) {
                    // subtract 2% charity fee from jackPot
                    charityFee = (jackPot * 2) / 100;
                    jackPot -= charityFee;
                    participants[i].transfer(jackPot);
                }
            }
        }        
    }
    
    /// Allow winner to withrawl their earnings
    function withdrawlWinnings () {
        
    }
}
