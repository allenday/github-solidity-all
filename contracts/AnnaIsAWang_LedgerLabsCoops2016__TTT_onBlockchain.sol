// Two major flaws right now: I'm ignoring the fact that I can't return 
// dynamic arrays and finished games are wasting memory space

contract TTT {
    
    struct Game {
        uint bet; // how much is at stake
        address x; // player that uses X
        address o; // player that uses O
        address turn; // who's turn is it
        uint8[] grid; // game board in form of array
        mapping (address => uint8) players; // to access the player's letter
        bool active;
    }
    // The idea is that each game has a bunch of attributes unique to it
    
    uint gridSize = 3; // changeable for abstraction
    uint8 constant X = 1; // arbitrary for compairson's sake
    uint8 constant O = 2; // ^^^
    Game[] games;
    uint numGames; // to avoid computing the length
    
    uint[] acceptableGames; // organized as kind of a 2D array of [id, bet]
    uint[] myGames; /// organized in the same way as above
    
    event AnotherGame(uint bet);
    event Moved(address who);
    event Won(address who, uint prize);
    event Finished();
    
    function fillBlank() internal returns(uint8[] blankgrid) { // only for creating new games
        for (uint i = 0; i < gridSize ** 2; ++i) {
            blankgrid[i] = 0;
        }
    }
    
    function TTT() {
        numGames = 0;
    }
    
    function newGame() returns (uint id) { // for starting new games
        if (msg.value <= 0) throw; // Don't want no weird money
        games[numGames] = Game(msg.value, msg.sender, 0, msg.sender, fillBlank(), false);
        games[numGames].players[msg.sender] = X; // Setting player x up
        id = numGames;
        ++numGames;
        AnotherGame(msg.value);
    }
    
    function accept(uint id) { // for accepting existing games
        if (id >= numGames || games[id].bet > msg.value) throw;
        Game g = games[id];
        if (g.bet < msg.value) {
            msg.sender.send(msg.value - g.bet); // send excess money back
        }
        g.o = msg.sender;
        g.bet *= 2;
        g.players[msg.sender] = O;
        g.active = true; // now the game is ready to be played
    }
    
    function checkWins(uint who, uint id, uint index) internal returns (bool) {
        uint z; // declare z and y up here for scoping reasons
        uint y;
        bool win = false;
        uint count;
        // check that row -
        count = 0;
        z = index / gridSize;
        for (y = 0; y < gridSize; ++y) {
            if (games[id].grid[gridSize * z + y] != who) {
                break;
            }
            ++count;
        }
            if (count == gridSize) {
                return true;
            }
        
        // check that column |
        count = 0;
        z = index - (index / gridSize) * index;
        for (y = 0; y < gridSize; ++y) {
            if (games[id].grid[z + gridSize * y] != who) {
                break;
            }
            ++count;
        }
            if (count == gridSize) {
                return true;
            }
        
        // check \
        if (index - (index / (gridSize + 1)) * index == 0) {
            for (z = 0; z < gridSize; ++z) {
                if (games[id].grid[(gridSize + 1) * z] != who) {
                    break;
                }
                return true;
            }
        }
        
        // check /
        if (index - (index / gridSize) * (index - 1))) {
            for (z = 0; z < gridSize; ++z) {
                if (games[id].grid[(gridSize - 1) * z] != who) {
                    break;
                }
                return true;
            }
            return false;
        }
    }
    
    function moves(address who, uint index, uint id) internal {
        if (!games[id].active|| msg.sender != who || games[id].grid[index] != 0) {
            throw;
        }
        games[id].grid[index] = games[id].players[who];
        Moved(who);
        bool tie;
        for (uint i = 0; i < gridSize ** 2; ++i) {
            if (games[id].grid[i] == 0) {
                tie = false;
                break;
            }
            tie = true; // so can only tie when the board is filled
        }
        if (checkWins(games[id].players[who], id, index)) { // short circuits so that wins takes priority over ties
            who.send(games[id].bet);
            Won(who, games[id].bet);
            games[id].active = false; // The game is over
        } else if (tie) {
            games[id].x.send(games[id].bet/2);
            games[id].o.send(games[id].bet - games[id].bet/2); // o was challenged so they can have the extra cen
            games[id].active = false; // The game is over
        }
    }
    
    function winner(uint index, uint id) returns (bool) {
        if (!games[id].active|| index >= gridSize ** 2 || index < 0 || id >= numGames) throw;
        if (msg.sender == games[id].x && games[id].turn == games[id].x) { // only proceed if it's my turn
            moves(games[id].x, index, id);
            if (games[id].active) {
                games[id].turn = games[id].o; // pass on the baton
            }
            return true;
        } else if (msg.sender == games[id].o && games[id].turn == games[id].o) {
            moves(games[id].o, index, id);
            if (games[id].active) {
                games[id].turn = games[id].x;
            }
            return true;
        } else {
            return false;
        }
    }
    
    function getState(uint id) constant returns (uint8[] grid) { // maybe need for JS
        grid = games[id].grid;
    }
    
    function getLetter(uint id) constant returns (uint8 letter) { // maybe need for JS
        if (msg.sender == games[id].x) {
            letter = X;
        } else if (msg.sender == games[id].o) {
            letter = O;
        }
    }
    
    function getCurrentGames() constant returns (uint[] present) { // maybe need for JS
        for (uint i = 0; i < numGames; ++i) {
            if (games[i].o == 0) {
                acceptableGames.push(i);
                acceptableGames.push(games[i].bet);
            }
        }
        present = acceptableGames;
        delete acceptableGames;
    }
    
    function getMyGames() constant returns (uint[] present) {
        for (uint i = 0; i < numGames; ++i) {
            if (games[i].active && 
            (games[i].x == msg.sender || games[i].o == msg.sender)) {
                myGames.push(i);
                myGames.push(games[i].bet);
            }
        }
        present = myGames;
        delete myGames;
    }
    
    // Notice how there's no kill function so your money is never eaten
    
    function () {
        msg.sender.send(msg.value);
    }
    
}
