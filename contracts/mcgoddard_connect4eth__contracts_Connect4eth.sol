pragma solidity ^0.4.6; // Specify compiler version

contract Connect4eth {
  address player1;
  address player2;
  bool player1sTurn;

  bool player1Paid;
  bool player2Paid;
  bool gameOver;
  
  address winningPlayer;

  uint bet;

  uint8[6][7] grid;
  
  function Connect4eth(address firstPlayer, address secondPlayer, uint b) {
    player1 = firstPlayer;
    player2 = secondPlayer;
    player1Paid = false;
    player2Paid = false;
    player1sTurn = true;
    gameOver = false;
    bet = b;
  }

  function joinGame() payable {
    if (msg.sender == player1 && !player1Paid && msg.value == bet) {
      player1Paid = true;
    }
    else if (msg.sender == player2 && !player2Paid && msg.value == bet) {
      player2Paid = true;
    }
    else {
      throw;
    }
  }

  function isStarted() constant returns (bool) {
    return player1Paid && player2Paid;
  }

  function isFinished() constant returns (bool) {
    return gameOver;
  }

  function isPlayer1sTurn() constant returns (bool) {
    if (!player1Paid || !player2Paid) throw;
    return player1sTurn;
  }

  function makeMove(uint8 col) {
    // check the game is in the correct state
    if (!isStarted() || gameOver) throw;
    // check the correct player is making the move
    uint8 player = 0;
    if (player1sTurn && msg.sender == player1) {
      player = 1;
    }
    else if (!player1sTurn && msg.sender == player2) {
      player = 2;
    }
    if (player == 0) throw;
    // check the column passed
    if (col > 6) throw;
    // try to make the move, will throw if the column is full
    for (uint8 i = 0; i < 8; i++) {
      if (grid[col][i] == 0) {
        grid[col][i] = player;
        break;
      }
    }
    // check if the game is won
    if (checkGrid(player)) {
      gameOver = true;
      if (player1sTurn) {
        winningPlayer = player1;
      }
      else {
        winningPlayer = player2;
      }
      if (!winningPlayer.send(this.balance)) throw;
    }
    // let the other player go
    else {
      player1sTurn = !player1sTurn;
    }
  }

  function checkGrid(uint8 player) private returns (bool) {
    // horizontalCheck 
    for (uint8 j = 0; j < 6-3 ; j++) {
        for (uint8 i = 0; i < 7; i++) {
            if (grid[i][j] == player && grid[i][j+1] == player && grid[i][j+2] == player && grid[i][j+3] == player) return true;
        }
    }
    // vertical check
    for (i = 0; i < 7-3 ; i++ ) {
        for (j = 0; j < 6; j++) {
            if (grid[i][j] == player && grid[i+1][j] == player && grid[i+2][j] == player && grid[i+3][j] == player) return true;
        }
    }
    // ascending diagonal check 
    for (i = 3; i < 7; i++) {
        for (j = 0; j < 6-3; j++) {
            if (grid[i][j] == player && grid[i-1][j+1] == player && grid[i-2][j+2] == player && grid[i-3][j+3] == player) return true;
        }
    }
    // descending diagonal check
    for (i = 3; i < 7; i++) {
        for (j = 3; j < 6; j++) {
            if (grid[i][j] == player && grid[i-1][j-1] == player && grid[i-2][j-2] == player && grid[i-3][j-3] == player) return true;
        }
    }
    return false; 
  }

  function getGrid() constant returns (uint8[6][7]) {
    return grid;
  }

  function getPlayer1() constant returns (address) {
    return player1;
  }

  function getPlayer2() constant returns (address) {
    return player2;
  }

  function getBet() constant returns (uint) {
    return bet;
  }
  
  function getWinner() constant returns (uint) {
    if (!isFinished()) throw;
    if (winningPlayer == player1) return 1;
    else if (winningPlayer == player2) return 2;
    return 0;
  }
}
