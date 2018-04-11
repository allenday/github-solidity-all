contract DivisibleGame {
    address owner;
    
//This is where the game details will be stored.  
struct Game {
  address player1;      //Person who creates the game
  uint numberChosen1;   //Number between 1-10 that the game creator (Player 1) chooses
  uint amountWagered;   //Amount the game creator chooses to bet, when a player joins the game they will send in the same amount 
  bool isDivisible;     //Player 1 chooses whether the outcome will be divisible by 2 (True) or not divisible by 2 (False)
  address player2;      //Person joining a game
  uint numberChosen2;   //Number between 1-10 that the person joining a game (Player 2) chooses
  bool gameOver;        //Flag to indicate the game is over.  This prevents the Game Details function being used prior to a game finishing.    
  uint amountTip;      //Game creator can choose if tip will be paid to developers.  Tip is a percentage of winning amount.
}


uint numGames = 0;      //Keeps track of the number of games and is used to provide the index number to the mapping

mapping (uint => Game) Games; //Essentially assigns the Game to a Game ID

modifier gameOver(uint gameID) //Used to prevent certain functions from being run prior to a game finishing
{
    if (Games[gameID].gameOver != false) 
    {
      throw;
    }
    _    
    
}

modifier gameNotOver(uint gameID) //Used to prevent certain functions from being run after a game is over
{
  if (Games[gameID].gameOver != true) 
  {
    throw;
  }
  _
  
}

//Creates a new game
  function newGame( uint numberChosen, bool _isDivisible, uint _amountTip) returns (uint gameID) 
  {
      if (numberChosen > 0 && numberChosen < 10) 
      {
        address _player1 = msg.sender;
        uint _amountBet = msg.value;
      
        gameID = numGames++;
        Games[gameID] = Game( _player1, numberChosen, _amountBet, _isDivisible,0,0,false, _amountTip);
        return gameID;
      }
  }

//Allows player to 'join' a game
  function playGame(uint numberChosen, uint gameID) gameOver(gameID)
  {
     if (msg.value == Games[gameID].amountWagered && numberChosen > 0 && numberChosen < 10)
     {
         uint _amountBet = msg.value;
         address _player2 = msg.sender;
         uint _gameID = gameID;
        
    
         Games[gameID].player2 = _player2;
         Games[gameID].amountWagered += _amountBet;
         Games[gameID].gameOver = true;
         Games[gameID].numberChosen2 = numberChosen;
        
        uint sumNumbers = Games[gameID].numberChosen1 + Games[gameID].numberChosen2;
        
        bool _isDivisible;
     
     if ( sumNumbers % 2 == 0) 
        _isDivisible = true;
     else 
        _isDivisible = false; 
     
     endGame(_isDivisible, _gameID);
     }    
     else throw;
      
        
  } 

//Private function the contract will call when it gets to the end of the playGame function.  Pays out winner.
  function endGame(bool isDivisibleResult, uint gameID) private
  {
    address _player1 = Games[gameID].player1;
    address _player2 = Games[gameID].player2;
    uint amountWon = Games[gameID].amountWagered - (Games[gameID].amountWagered * (Games[gameID].amountTip/100));
    uint amountTipped = Games[gameID].amountWagered * (Games[gameID].amountTip/100);
    bool betDivisible = Games[gameID].isDivisible;
    
      if (isDivisibleResult == true && betDivisible == true || isDivisibleResult == false && isDivisibleResult == false)
      {
          if (_player1.send(amountWon)==false) throw;

      }   else if (_player2.send(amountWon)==false) throw;

    
  }
  
//Returns details of a specific game based on the Game ID given to the function.  Mainly for testing purposes right now.  
  function getGameDetails(uint gameID) gameNotOver(gameID) constant returns(address _player1, uint _numberChosen1, uint _amountWagered, address _player2, uint _numberChosen2, bool _gameOver)
  {
     _player1 = Games[gameID].player1;
     _numberChosen1 = Games[gameID].numberChosen1;
     _amountWagered = Games[gameID].amountWagered;
     _player2 = Games[gameID].player2;
     _numberChosen2 = Games[gameID].numberChosen2;
     _gameOver = Games[gameID].gameOver;
     
     
     return (_player1, _numberChosen1, _amountWagered, _player2, _numberChosen2, _gameOver);
  }
  
//Returns the number of games that have been created so far.  Mainly for testing purposes right now.  
  function getNumberOfGames() constant returns (uint _numGames)
  {
      _numGames = numGames;
      return;
  }
  
//Destroys contract.
  function kill() {if (msg.sender == owner) selfdestruct(owner);}

//Fallback function
  function()
  {
      throw;
  }



  }
