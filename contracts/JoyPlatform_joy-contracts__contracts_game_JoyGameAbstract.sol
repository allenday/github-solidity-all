pragma solidity ^0.4.11;

import '../ownership/Ownable.sol';


contract JoyGameAbstract is Ownable {

    /**
     * gameDevAddr is a developer of a game, this address is needed at the end of each game session;
     * part of platform profits will be distributed to this address
     */
    address public gameDev;

    // Event that will broadcast in blockchain information about new game session
    event NewGameSession(address indexed player, uint256 start_balance);

    // Event that will broadcast in blockchain information about finite game session
    event EndGameInfo(address indexed player, uint256 start_balance, uint256 finalBalance, bytes32 indexed hashOfGameProcess);

    /**
     * @dev Abstract external function that starts game session.
     * @param _playerAddr Player address
     * @param _value that will be given to the player in game session
     */
    function startGame(address _playerAddr, uint256 _value) external;

    /**
     * @dev struct containg outcome of the game, with provable hash, that could be match with game history in GS
     * (or mayby it could be cryptoanlyzed/mined)
     */
    struct GameOutcome {
        address player;
        uint256 finalBalance;
        // Hashed course of the finite game
        bytes32 hashOfGameProcess;
    }

    /**
     * @dev Abstract internal function that end game session
     * @param _gameOutcome Game output provided from game instance
     */
    function endGame(GameOutcome _gameOutcome) internal;

}
