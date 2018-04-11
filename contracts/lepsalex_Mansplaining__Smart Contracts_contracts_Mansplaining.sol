pragma solidity ^0.4.4;

import './Mortal.sol';
import './MPGame.sol';

/*
 * Mansplaining
 * A simple contract that acts as the back-end for our
 * real-world mansplaining game scoreboard
*/
contract Mansplaining is Mortal {

	event NewGame(address indexed gameAddress);
	event GameOver(address indexed gameAddress);
	
	// Create new game contract
	function createGame(uint8 initPoints) {
        MPGame newGame = new MPGame(initPoints);
		NewGame(newGame);
	}

	// Destroy game and all players creatd by game
	function endGame(address instance) {
		MPGame game = MPGame(instance);
        game.kill();
		GameOver(instance);
	}
}
