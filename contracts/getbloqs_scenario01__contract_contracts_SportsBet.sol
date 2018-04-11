pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract SportsBet is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint8;

    //struct Bet {        
    //    uint8 tip;
    //    uint256 amount;
    //}
    //mapping (address => Bet) public bets;

    // all bets accessible by address of investor    
    mapping (address => uint256) public betAmounts;
    mapping (address => uint8) public betTips;

    // identifier for winning tip 1, 2 or 3
    uint8 public winningTip;

    // total amount inside bet
    uint256 public total;

    // the amounts invested split for each bet
    uint256[3] public amounts;
        
    // a identifier for the game to bet on
    string public game;

    // timestamp to mark the end of betting
    uint256 public endOfBetting;

    function SportsBet(string _game, uint256 _endOfBetting) public {
        require(now < _endOfBetting);

        game = _game;
        endOfBetting = _endOfBetting;
    }

    function bet(uint8 _tip) payable external {
        require(now < endOfBetting);
        uint8 tip = checkTip(_tip);

        // if sender already did a bet, the
        // bet can only be increased in value
        if (betTips[msg.sender] == 0) {
            betTips[msg.sender] = tip;
        }      

        betAmounts[msg.sender] = betAmounts[msg.sender].add(msg.value);
        amounts[betTips[msg.sender].sub(1)] = amounts[betTips[msg.sender].sub(1)].add(msg.value);
        total = total.add(msg.value);
    }

    function payout() external {
        // if bet is finalized and sender made a winning tip
        require(
            winningTip > 0 &&
            betTips[msg.sender] == winningTip &&
            betAmounts[msg.sender] > 0
        );
        
        uint256 odds = calculateOdds(winningTip);
        uint256 out = betAmounts[msg.sender].mul(odds);

        // payout can only be done if there is more in the contracts balance
        if (this.balance >= out) {
            betAmounts[msg.sender] = 0;
            msg.sender.transfer(out);
        }      
    }

    function finalizeBet(uint8 _winningTip) external onlyOwner {
        winningTip = checkTip(_winningTip);
    }

    function calculateOdds(uint8 _tip) public view returns(uint256) {
        uint8 tip = checkTip(_tip);
        return total.mul(100).div(amounts[tip.sub(1)]).div(100);
    }

    /**
        @dev Prevent invalid tips, only 1, 2, 3 is allowed
        @param tip tip to be checked
        @return a valid tip
    */
    function checkTip(uint8 tip) public pure returns (uint8) {
        if (tip <= 1) {
            return 1;
        } else if (tip >= 3) {
            return 3;
        } else {
            return 2;
        }        
    }
}
