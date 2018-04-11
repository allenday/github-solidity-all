pragma solidity ^0.4.18;

import './SportsBet.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract SportsBetFactory {
    using SafeMath for uint256;

    uint256 public betCount = 0;
    mapping (string => address) betInstances;
    mapping (uint256 => string) public betInstanceIndex;
    
    function createSportsBet(string _game, uint256 _endOfBetting) public {
        // require a unique name for each bet
        require(betInstances[_game] == address(0)); 

        SportsBet bet = new SportsBet(_game, _endOfBetting);
        bet.transferOwnership(msg.sender);
        
        betInstances[_game] = bet;
        betInstanceIndex[betCount] = _game;
        betCount = betCount.add(1);
    }

    function getBet(uint256 _index) view public returns (string, address) {
        string memory name = betInstanceIndex[_index];        
        address bet = betInstances[name];

        require(bet != address(0));
        return (name, bet);
    }

}