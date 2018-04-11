/*
    schellingLight.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./module.sol";
import "./owned.sol";
import "./safeMath.sol";
import "./moduleHandler.sol";

contract schelling is module, owned, safeMath {
    /* Module functions */
    function transferEvent(address from, address to, uint256 value) external onlyForModuleHandler returns (bool success) {
        /*
            Transaction completed. This function can be called only by the ModuleHandler. 
            If this contract is the receiver, the amount will be added to the prize pool of the current round.
            
            @from      From who
            @to        To who
            @value     Amount
            
            @success   Was the transaction succesfull?
        */
        if ( to == address(this) ) {
            rewards = safeAdd(rewards, value);
        }
        return true;
    }
    function configureModule(announcementType aType, uint256 value, address addr) external onlyForModuleHandler returns(bool success) {
        /*
            Can be called only by the ModuleHandler.
            
            @aType      Sort of configuration
            @value      Value
        */
        require( super.isModuleHandler(msg.sender) );
        if      ( aType == announcementType.schellingRoundBlockDelay )     { roundBlockDelay = value; }
        else if ( aType == announcementType.schellingCheckRounds )         { }
        else if ( aType == announcementType.schellingCheckAboves )         { }
        else if ( aType == announcementType.schellingRate )                { interestRate = value; }
        else { return false; }
        super._configureModule(aType, value, addr);
        return true;
    }
    /* Variables */
    uint256 public roundBlockDelay     = 720;
    uint256 public interestRate        = 300;
    uint256 public interestRateM       = 1e3;   
    
    uint256 public currentSchellingRoundID = 1;
    uint256 public currentSchellingRoundStart = safeAdd(block.number, roundBlockDelay);
    uint256 public rewards = 0;
    address public escrow = 0xd3fc97709b5b37c67d3d702f7a5fe122d863abbd;
    /* Constructor */
    function schelling(address moduleHandlerAddr) module(moduleHandlerAddr) {
        owner = 0xa22dd0bb010e9536832e95f4fe8a2d740f9f2799;
    }
    /* Externals */
    function newSchellingRound(bool release) external {
        require( isOwner() );
        require( currentSchellingRoundStart <= block.number );
        currentSchellingRoundStart = safeAdd(block.number, roundBlockDelay);
        currentSchellingRoundID = safeAdd(currentSchellingRoundID, 1);
        uint256 _reward;
        if ( release ) {
            _reward = safeMul(getTotalSupply(), interestRate) / interestRateM / 100;
        }
        require( moduleHandler(moduleHandlerAddress).broadcastSchellingRound(currentSchellingRoundID, _reward) );
        require( moduleHandler(moduleHandlerAddress).transfer(address(this), escrow, rewards, false) );
        delete rewards;
        ENewSchellingRound(currentSchellingRoundID, _reward);
    }
    /* Internals */
    function getTotalSupply() internal returns (uint256 amount) {
        var (_success, _amount) = moduleHandler(moduleHandlerAddress).totalSupply();
        require( _success );
        return _amount;
    }
    /* Constants */
    function getCurrentSchellingRoundID() public constant returns(bool success, uint256 roundID) {
        return ( true, currentSchellingRoundID );
    }
    event ENewSchellingRound(uint256 roundID, uint256 reward);
}
