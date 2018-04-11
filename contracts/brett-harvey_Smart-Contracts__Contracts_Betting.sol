/**************
 * Filename: MyBetting.sol
 * Author: Brett Harvey 
 * Date: November 2nd 2017
***************/

pragma solidity ^0.4.16;

contract MyBetting {

    struct Bet {
        uint BetID;
        uint wager;
        address User1;
        address User2;
    }
    
    uint public TotalAmountOfBets;
    
    mapping (uint => Bet) Bets;
    mapping (address => Bet) MyBets; 
    
    event NewBetCreated(address Player1, address Player2, uint AmountOfWager);
    
    function MyBetting() public  {
        
    }
    /*
    function CreateABet(address Opponent, uint betAmount) public {
        Bets[TotalAmountOfBets] = Bet(TotalAmountOfBets,
        betAmount, msg.sender, Opponent);
        MyBets[msg.sender] = Bets[TotalAmountOfBets];
        NewBetCreated(msg.sender, Opponent, betAmount);
        TotalAmountOfBets++;
    }
*/    
    function BetMe(address Opponent, uint AmountOfWager) payable {
        require(msg.sender.balance >= AmountOfWager * 2);
    }
    
    function ViewBetByID(uint ID) public constant returns (Bet)  {
        return Bets[ID];
    }
    
    function ViewtMyBets() public constant returns (Bet)  {
        return MyBets[msg.sender];
    }
}
