pragma solidity 0.4.15;

import "./Ownable.sol";

contract Pauseable is Ownable{
    bool public paused;

    event LogSetPaused(address indexed who, bool indexed paused);

    modifier isPaused(){
        require(paused);
        _;
    }

    modifier isNotPaused(){
        require(!paused);
        _;
    }

    function setPaused(bool newPaused) public isOwner returns(bool success) {
        require(newPaused != paused);
        paused = newPaused;
        LogSetPaused(owner, newPaused);
        return true;
    }
}
