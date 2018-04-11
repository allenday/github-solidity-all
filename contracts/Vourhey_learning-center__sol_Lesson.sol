pragma solidity ^0.4.4;
import './Dealer.sol';

/**
 * @title The lesson base contract
 */
contract Lesson is Owned {
    // dealer
    Dealer public dealer;

    function setDealer(Dealer _dealer) onlyOwner
    { dealer = _dealer; }
    
    // Lesson reward
    uint public reward;

    function setReward(uint _reward) onlyOwner
    { reward = _reward; }

    // Address passed the lesson
    mapping(address => bool) public isPassed;

    /**
     * @dev The lesson base constructor
     * @param _dealer is an dealer
     * @param _reward is a lesson reward
     */
    function Lesson(address _dealer, uint _reward) {
        dealer    = Dealer(_dealer);
        reward = _reward;
    }

    /**
     * @dev This function called when lesson assertion passed
     * @param _sender is a sender address
     */
    function passed(address _sender) internal {
        // Throw wnen sender already pass me
        if (isPassed[_sender]) throw;

        isPassed[_sender] = true;
        dealer.pay(_sender, reward);
    }
}
