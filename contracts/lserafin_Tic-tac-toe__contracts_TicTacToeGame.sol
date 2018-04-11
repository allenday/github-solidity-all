pragma solidity ^0.4.4;

//3x3 Tic Tac Toe Game
contract TicTacToeGame {
	address owner;
    address opponent;
    
    address winner;
    address currentPlayer;
    
    GameStatus currentGameStatus;
    enum GameStatus { NotStarted, InProgress, Ended }
    
	/*
    *
    *   0 | 1 | 2
    *  ---+---+---
    *   3 | 4 | 5
    *  ---+---+---
    *   6 | 7 | 8
    *
    */
    mapping (uint8 => address) board;

	function TicTacToeGame() public { 
	    owner = msg.sender;
	    currentPlayer = owner;
	    
	    for (uint8 i = 0; i < 9; i++) {
	        board[i] = address(0);
	    }
	    
	    currentGameStatus = GameStatus.NotStarted;
	    
	}
	
	function getOpponent() public returns (address) {
	    return opponent;
	}
	
	function getGameStatus() public returns (GameStatus) {
	    return currentGameStatus;
	}
	
	function acceptGame() public returns (bool) {
	    require(opponent == address(0));
	    require(owner != msg.sender);
	    opponent = msg.sender;
	    currentGameStatus = GameStatus.InProgress;
	}
	
	function getPosition(uint8 position) public returns (address) {
	    require(position >= 0 && position < 9);
	    return board[position];
	}
	
	function placeMove(uint8 position) public returns (bool) {
	    require(currentGameStatus == GameStatus.InProgress); //To make a move the game has to be InProgress
	    require(currentPlayer == msg.sender); //Must the the current player
	    require(position >= 0 && position < 9);
	    require(board[position] == address(0)); //Position must be empty
	    board[position] = msg.sender;
	    currentPlayer = opponent;
	    checkGameStatus();
	}
	
	function checkGameStatus() private {
	    if (board[0] != address(0) && board[0] == board[1] && board[1] == board[2]) { //First row
	        winner = board[0];
	        currentGameStatus = GameStatus.Ended;
	    } else if (board[3] != address(0) && board[3] == board[4] && board[4] == board[5]) { //Second row
	        winner = board[3];
	        currentGameStatus = GameStatus.Ended;
	    } else if (board[6] != address(0) && board[6] == board[7] && board[7] == board[8]) { //Third row
	        winner = board[6];
	        currentGameStatus = GameStatus.Ended;
	    } else if (board[0] != address(0) && board[0] == board[3] && board[3] == board[6]) { //First column
	        winner = board[0];
	        currentGameStatus = GameStatus.Ended;
	    } else if (board[1] != address(0) && board[1] == board[4] && board[4] == board[7]) { //Second column
	        winner = board[1];
	        currentGameStatus = GameStatus.Ended;
	    } else if (board[2] != address(0) && board[2] == board[5] && board[5] == board[8]) { //Third column
	        winner = board[2];
	        currentGameStatus = GameStatus.Ended;
	    } else if (board[0] != address(0) && board[0] == board[4] && board[4] == board[8]) { //Left top to right below
	        winner = board[0];
	        currentGameStatus = GameStatus.Ended;
	    } else if (board[6] != address(0) && board[6] == board[4] && board[4] == board[2]) { //Left buttom to right top
	        winner = board[6];
	        currentGameStatus = GameStatus.Ended;
	    }
	}
    
}
