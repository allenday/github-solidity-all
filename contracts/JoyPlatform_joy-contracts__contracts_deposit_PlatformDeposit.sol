pragma solidity ^0.4.11;

import '../math/SafeMath.sol';
import '../token/JoyToken.sol';
import '../token/ERC223ReceivingContract.sol';
import '../ownership/Ownable.sol';
import '../game/JoyGameAbstract.sol';

/**
 * Main token deposit contract.
 *
 * In demo version only playing in on game at the same time is allowed,
 * so locks, unlocks, and transfer function operate on all player deposit.
 */
contract PlatformDeposit is ERC223ReceivingContract, Ownable {
    using SafeMath for uint;

    // Token that is supported by this contract. Should be registered in constructor
    JoyToken public m_supportedToken;

    mapping(address => uint256) deposits;
    mapping(address => uint256) lockedFunds;

    /**
     * platformReserve - Main platform address and reserve for winnings
     * Important address that collecting part of players losses as reserve which players will get winnings.
     * For security reasons "platform reserve address" needs to be separated/other that address of owner of this contract.
     */
    address public platformReserve;

    /**
     * @dev Constructor
     * @param _supportedToken The address of token contract that will be supported as players deposit
     */
    function PlatformDeposit(address _supportedToken, address _platformReserve) {
        // owner need to be separated from _platformReserve
        require(owner != _platformReserve);

        platformReserve = _platformReserve;
        m_supportedToken = JoyToken(_supportedToken);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _player The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOfPlayer(address _player) public constant returns (uint256) {
        return deposits[_player];
    }

    /**
     * @dev Gets the locked funds of the specified address.
     * @param _player Player address.
     * @return An uint256 representing the amount of locked tokens.
     */
    function playerLockedFunds(address _player) public constant returns (uint256) {
        return lockedFunds[_player];
    }

    /**
     * @dev Function that receive tokens, throw exception if tokens is not supported.
     * This contract could receive tokens, using functionalities designed in erc223 standard.
     * !! works only with tokens designed in erc223 way.
     */
    function onTokenReceived(address _from, uint _value, bytes _data) external {
        // msg.sender is a token-contract address here
        // we will use this information to filter what token we accept as deposit

        // get address of supported token
        require(msg.sender == address(m_supportedToken));
        //TODO make sure about other needed requirements!

        deposits[_from] = deposits[_from].add(_value);
    }

    /**
     * @dev Temporarily transfer funds to the game contract
     *
     * This method can be used to lock funds in order to perform specific actions by external contract.
     * That construct allow to adding new games without modifying this contract.
     * Important security check is that execution of this method will work:
     *  only if the owner of the game will be same as the owner of this contract
     *
     * @param _player address of registered player
     * @param _gameContractAddress address to the game contract
     */
    function transferToGame(address _player, address _gameContractAddress) onlyOwner {
        // platformReserve is not allowed to play, this check prevents owner take possession of platformReserve
        require(_player != platformReserve);

        // _gameContractAddress should be a contract, throw exception if owner will tries to transfer funds to the individual address.
        // Require supported Token to have 'isContract' method.
        require(isContract(_gameContractAddress));

        // check if player have any funds in his deposit
        require(deposits[_player] > 0);

        // Create local joyGame object using address of given gameContract.
        JoyGameAbstract joyGame = JoyGameAbstract(_gameContractAddress);

        // Require this contract and gameContract to be owned by the same address.
        // This check prevents interaction with this contract from external contracts
        require(joyGame.owner() == owner);

        uint256 loc_fundsLocked = lockPlayerFunds(_player);

        // increase gameContract deposit for the time of the game
        // this funds are locked, and can not even be withdraw by owner
        deposits[_gameContractAddress] = deposits[_gameContractAddress].add(loc_fundsLocked);

        joyGame.startGame(_player, loc_fundsLocked);
    }

    /**
     * @dev  move given _value from player deposit to lockedFunds map.
     * Should be unlocked only after end of the game session (accountGameResult function).
     */
    function lockPlayerFunds(address _playerAddr) internal returns (uint256 locked) {
        uint256 player_deposit = deposits[_playerAddr];
        deposits[_playerAddr] = deposits[_playerAddr].sub(player_deposit);

        // check if player funds was locked successfully
        require(deposits[_playerAddr] == 0);

        lockedFunds[_playerAddr] = lockedFunds[_playerAddr].add(player_deposit);

        return lockedFunds[_playerAddr];
    }

    /**
     * @dev internal function that unlocks player funds.
     * Used in accountGameResult after
     */
    function unlockPlayerFunds(address _playerAddr) internal returns (uint256 unlocked) {
        uint256 player_lockedFunds = lockedFunds[_playerAddr];
        lockedFunds[_playerAddr] = lockedFunds[_playerAddr].sub(player_lockedFunds);

        // check if player funds was unlocked successfully
        require(lockedFunds[_playerAddr] == 0);

        deposits[_playerAddr] = deposits[_playerAddr].add(player_lockedFunds);

        return deposits[_playerAddr];
    }

    /**
     * @dev function that can be called from registered 'game contract' after closing player session to update state.
     *
     * Unlock Tokens from game contract and distribute Tokens according to final balance.
     * @param _playerAddr address of player that end his game session
     * @param _finalBalance value that determine player wins and losses
     */
    function accountGameResult(address _playerAddr, uint256 _finalBalance) external {

        JoyGameAbstract joyGame = JoyGameAbstract(msg.sender);

        // check if game contract is allowed to interact with this contract
        // must be the same owner
        require(joyGame.owner() == owner);

        // case where player deposit does not change
        if(_finalBalance == lockedFunds[_playerAddr]) {
            unlockPlayerFunds(_playerAddr);
        }
        // case where player wins
        else if (_finalBalance > lockedFunds[_playerAddr]) {
            uint256 playerEarnings = _finalBalance.sub(lockedFunds[_playerAddr]);

            // check if contract is able to pay player a win
            require(playerEarnings <= deposits[platformReserve]);

            // unlock player funds with additional win from platformReserve
            unlockPlayerFunds(_playerAddr);

            deposits[platformReserve] = deposits[platformReserve].sub(playerEarnings);
            deposits[_playerAddr] = deposits[_playerAddr].add(playerEarnings);
        }
        // case where player lose
        else {
            // substract player loss from player locked funds
            uint256 playerLoss = lockedFunds[_playerAddr].sub(_finalBalance);
            lockedFunds[_playerAddr] = lockedFunds[_playerAddr].sub(playerLoss);

            // double check
            require(lockedFunds[_playerAddr] == _finalBalance);

            // unlock player funds that were not lose
            unlockPlayerFunds(_playerAddr);

            // distribute player Token loss to gameDev and platformReserve in 1:1 ratio
            // for odd loss additional Token goes to platformReserve
            // (example loss = 3 is gameDevPart = 1 and platformReserve = 2)
            uint256 gameDeveloperPart = playerLoss.div(2);
            uint256 platformReservePart = playerLoss.sub(gameDeveloperPart);

            // double check
            require( (gameDeveloperPart + platformReservePart) == playerLoss );

            address loc_gameDev = joyGame.gameDev();

            deposits[loc_gameDev] = deposits[loc_gameDev].add(gameDeveloperPart);
            deposits[platformReserve] = deposits[platformReserve].add(platformReservePart);
        }

    }

    /**
     * @dev Function that could be executed by players to withdraw their deposit
     */
    function payOut(address _to, uint256 _value) {
        // use transfer function from supported token.
        // should be used from player address that was registered in deposits
        require(_value <= deposits[msg.sender]);

        /**
         * Prevents payOut to the contract address.
         * This trick deprives owner incentives to steal Tokens from players.
         * Even if owner use 'transferToGame' method to transfer some deposits to the fake contract,
         * he will not be able to withdraw Tokens to any private address.
         */
        require(isContract(_to) == false);

        deposits[msg.sender] = deposits[msg.sender].sub(_value);

        // Use m_supportedToken method to transfer real Tokens.
        m_supportedToken.transfer(_to, _value);
    }

    //---------------------- utils ---------------------------

    function isContract(address _addr) internal constant returns (bool) {
        uint codeLength;
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_addr)
        }
        return (codeLength > 0);
    }
}
