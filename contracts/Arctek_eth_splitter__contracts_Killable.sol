pragma solidity 0.4.15;

import "./Pauseable.sol";

contract Killable is Pauseable{
    bool public killed;
    bool public isWithdrawn;

    event LogKill(address indexed who);
    event LogEmergencyWithdrawal(address indexed who, uint withdrawalAmount);

    modifier isKilled(){
        require(killed);
        _;
    }

    modifier isNotKilled(){
        require(!killed);
        _;
    }

    function kill() public isOwner isPaused isNotKilled returns(bool success){
        killed = true;
        LogKill(msg.sender);
        return true;
    }

    function emergencyWithdrawal() public isOwner isKilled returns(bool success){
        require(!isWithdrawn);
        isWithdrawn = true;
        
        LogEmergencyWithdrawal(msg.sender, this.balance);
        msg.sender.transfer(this.balance);
        //suicide??
        return true;
    }
}