pragma solidity ^0.4.11;

import '../deposit/PlatformDeposit.sol';
import '../math/SafeMath.sol';
import '../ownership/Ownable.sol';
import './JoyGameAbstract.sol';



/**
 * @title JoyGameDemo
 * Contract that is responsible only for one game, and uses external given deposit contract
 */
contract JoyGameDemo is JoyGameAbstract {
    using SafeMath for uint;

    /**
     * @dev map containing information if given player have open game session.
     */
    mapping(address => bool) public openSessions;

    /**
     * Deposit contract that manage players funds in long-term,
     * deposit contract also contain information about supported token,
     * that will be supported also in this contract.
     */
    PlatformDeposit public m_playerDeposits;

    /**
     * @dev get amount of locked funds from coresponding to this contracti, deposit contract
     * Funds that are locked for the time of the game and waiting for game outcome.
     */
    function playerLockedFunds(address _player) public view returns (uint256) {
        return m_playerDeposits.playerLockedFunds(_player);
    }

    /**
     * Main constructor, that register source of value that will be used in games (depositContract)
     * and developer of the game
     * @param _depositContract address of already deployed depositContract
     * @param _gameDev address of game creator
     */
    function JoyGameDemo(address _depositContract, address _gameDev) {

        m_playerDeposits = PlatformDeposit(_depositContract);

        // Require this contract and depositContract to be owned by the same address.
        // This check prevents connecting to external malicious contract
        require(m_playerDeposits.owner() == owner);

        gameDev = _gameDev;
    }

    //----------------------------------------- start session -----------------------------------------

    /**
     * Override function
     * @dev Brings information about locked tokens from player_account on depositContract for the time of the game.
     * @param _player Player address
     * @param _value that will be given to the player in game session
     */
    function startGame(address _player, uint256 _value) external {
        // only registred depositContract is allowed to execute this function
        require(msg.sender == address(m_playerDeposits));

        // don't allow player to have two open sessions
        require(openSessions[_player] == false);

        // Check if calling contract is registred as m_playerDeposits,
        // non registred contracts are not allowed to affect to this game contract
        require(msg.sender == address(m_playerDeposits));

        openSessions[_player] = true;

        // brodcast logs in blockchain about new session
        // listening game server should start game after confirmation transaction containing execution of this function
        NewGameSession(_player, _value);
    }

    //----------------------------------------- end session -------------------------------------------

    function responseFromWS(address _playerAddr, uint256 _finalBalance, bytes32 hashOfGameProcess) onlyOwner {
        endGame( GameOutcome(_playerAddr, _finalBalance, hashOfGameProcess) );
    }

    /**
     * Override function
     * @dev Save provable outcome of the game and distribute Tokens to gameDev, platform, and player
     * @param _gameOutcome struct with last updated amount of the WS wallets along with the Hash of provable data
     */

    function endGame(GameOutcome _gameOutcome) internal {
        // Save initial player funds to stack variable
        uint256 gameLockedFunds = playerLockedFunds(_gameOutcome.player);

        // double check if given player had possibility to play.
        // his lockedDeposit needed to be non-zero/positive.
        require(gameLockedFunds > 0);

        // Initial wrapping and real Tokens distribiution in deposit contract
        m_playerDeposits.accountGameResult(_gameOutcome.player, _gameOutcome.finalBalance);

        // close player game session
        openSessions[_gameOutcome.player] = false;

        // populate finite game info in transaction logs
        EndGameInfo(_gameOutcome.player,
                    gameLockedFunds,
                    _gameOutcome.finalBalance,
                    _gameOutcome.hashOfGameProcess);
    }
}
