pragma solidity ^0.4.4;

import './Mortal.sol';

contract MPGame is Mortal {
    

    // Player type
    struct Player {
        bytes32 email;
        bytes32 name;
        bytes6 colour;
    }

    // We will use game state enum to control whether or not we can move points around
	// and do any other gameplay actions
	enum GAME_STATE {
		locked,
		ready
	}
	GAME_STATE gameState;

	uint8 maxPoints = 100;
    uint8 gamePoints;

    uint8 maxPlayers = 4; // only four buttons on my internet button :(
	uint8 currentNumPlayers = 0;

    mapping(bytes32 => Player) players;
    mapping(bytes32 => uint8) scores;
    Player[] playersIter; // iterable player storage

    // Notifies front-end of player added and how many more players can join
    event PlayerAdded(string playerEmail, uint8 slotsAvailable);

    // Notifies front-end that we are ready to play the game
    event GameReady(bool isReady);

    // Notifies of player point received
    event PointReceived(string playerEmail, uint8 playerScore);

    function MPGame(uint8 initPoints) {
        require(initPoints <= maxPoints);

        // Set points to points available
		gamePoints = initPoints;

        // Set game to locked (until players have all been added)
		gameState = GAME_STATE.locked;
    }

    function addPlayer(bytes32 playerEmail, bytes32 playerName, bytes6 playerColour) external {

		// Do not allow more players than max or additon of players mid game
		require(currentNumPlayers < maxPlayers && gameState == GAME_STATE.locked);

		// Issue new player contract, save address mapped to their email
        Player memory newPlayer = Player(playerEmail, playerName, playerColour);
        players[playerEmail] = newPlayer;
        playersIter.push(newPlayer);
		
		currentNumPlayers++;

        PlayerAdded(bytes32ToString(playerEmail), maxPlayers - currentNumPlayers);
	}

    function awardPoint(bytes32 playerEmail) external {
        require(gameState == GAME_STATE.ready && gamePoints > 0);
        gamePoints--;
        scores[playerEmail]++;
        PointReceived(bytes32ToString(playerEmail), scores[playerEmail]);
    }

    function getPlayerPoints(bytes32 playerEmail) constant returns(uint8) {
        return scores[playerEmail];
    }

    function getPointsBalance() constant returns(uint8) {
        return gamePoints;
    }

    function bytes32ToString (bytes32 data) internal returns (string) {
        bytes memory bytesString = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * i)));
            if (char != 0) {
                bytesString[i] = char;
            }
        }
        return string(bytesString);
    }

    // Unlocks game for play if conditions met
	function startGame() {
		require(currentNumPlayers >= 1);
		gameState = GAME_STATE.ready;
        GameReady(true);
	}
}