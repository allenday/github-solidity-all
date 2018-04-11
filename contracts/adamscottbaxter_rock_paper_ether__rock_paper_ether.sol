pragma solidity ^0.4.11;

contract RockPaperScissors {

    enum Stages {
        playerOneThrow,
        playerTwoThrow,
        playerOneReveal,
        playerTwoReveal,
        determineWinner
    }
    
    Stages public stage = Stages.playerOneThrow;
    
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    
    function nextStage() internal {
        stage = Stages(uint(stage) + 1);
    }
    
    Player public player1;
    Player public player2;
    uint public bet = 0;
    uint public resetTime;
    address public winner;
    
    struct Player{
        address addy;
        bytes32 commitHash;
        uint commitTime;
        bytes32 gameThrow;
        uint revealTime;
    }
    
    function RockPaperScissors(address _player1, address _player2, uint _bet)  {
        player1.addy = _player1;
        player2.addy = _player2;
        bet = _bet;
    }

    modifier includesPayment(){if(msg.value == bet){ _; }else{ throw; } }
    
    function playerOneCommit(bytes32 commitHash) payable atStage(Stages.playerOneThrow) includesPayment() {
        if(msg.sender == player1.addy) {
            player1.commitHash = commitHash;
            player1.commitTime = now;
            resetTime = 0;
            nextStage();
        } else {
            throw;
        }
    }
    
    function playerTwoCommit(bytes32 commitHash) payable atStage(Stages.playerTwoThrow) includesPayment() {
        if(msg.sender == player2.addy) {
            player2.commitHash = commitHash;
            player2.commitTime = now;
            nextStage();
        } else {
            throw;
        }
    }
    

    function playerOneReveal(bytes32 gameThrow, bytes32 secret) atStage(Stages.playerOneReveal) {
        bytes32 commitHash = sha3(gameThrow, secret);
        if(commitHash == player1.commitHash) {
            player1.gameThrow = gameThrow;
            player1.revealTime = now;
            nextStage();
        } else {
            throw;
        }
    }
    
    function playerTwoReveal(bytes32 gameThrow, bytes32 secret) atStage(Stages.playerTwoReveal) {
        bytes32 commitHash = sha3(gameThrow, secret);
        if(commitHash == player2.commitHash) {
            player2.gameThrow = gameThrow;
            player2.revealTime = now;
            nextStage();
            determineWinner();
        } else {
            throw;
        }
    }

    function determineWinner() atStage(Stages.determineWinner) {
        
        if(player1.gameThrow == 1 && player2.gameThrow == 2) {
            winner = player2.addy;
        } else if(player1.gameThrow == 2 && player2.gameThrow == 3) {
            winner = player2.addy;
        } else if(player1.gameThrow == 3 && player2.gameThrow == 1) {
            winner = player2.addy;
        } else if (player1.gameThrow != player2.gameThrow) {
            winner = player1.addy;
        }
        
        if(winner != 0x0) {
            winner.transfer(this.balance);
        } else { //tie
            reset();
        }
    }
    
    function returnFunds(){
        if(stage == Stages.playerOneThrow){
            if(player1.commitHash == 0 && now > resetTime + 3600){
                splitFunds();
            }
        }
        if(stage == Stages.playerTwoThrow){
            if(now > player1.commitTime + 3600){
                player1.addy.transfer(this.balance);
            }
        }
        if(stage == Stages.playerOneReveal){
            if(now > player2.commitTime + 3600){
                player2.addy.transfer(this.balance); // or splitFunds() ?
            }
        }
        if(stage == Stages.playerTwoReveal){
            if(now > player1.revealTime + 3600){
                player1.addy.transfer(this.balance);
            }
        }
    }
    
    function splitFunds() private{
        player1.addy.transfer(this.balance/2);
        player2.addy.transfer(this.balance/2);
        reset();
    }
    
    function reset() private{
        delete player1.commitHash; 
        delete player1.gameThrow;
        delete player1.commitTime;
        delete player1.revealTime;
        delete player2.commitHash;
        delete player2.gameThrow;
        delete player2.commitTime;
        delete player2.revealTime;
        resetTime = now;
        stage = Stages.playerOneThrow;
    }
}