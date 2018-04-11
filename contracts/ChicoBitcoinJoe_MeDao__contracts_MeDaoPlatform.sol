pragma solidity ^0.4.11;

import "browser/MiniMeToken.sol";

/*
    Copyright 2017, Joseph Reed

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MeDao Contract
/// @author Joseph Reed
/// @dev The MeDao platform enables any person to find a free market value for 
///     their own time, and allow anyone in the world to gain exposure to the 
///     value of that person's time. This is acheived by giving the MeDao Founder
///     40 hours worth of tokens each week to distribute as they see fit. Most of
///     the time this will mean selling it on a MeDao Exchange. Intrinsically,
///     each token represents 1 second of the Founder's time but do not have to 
///     be used right away and can be held until the owner wishes to cash in the
///     time with the Founder or sell them on the open market. A burn function is
///     provided for making payments to a MeDao thus showing proof of work done 
///     by the MeDao Founder. A MiniMeToken with a clone feature enables the
///     Founder to add value to their token in unique ways. For examples see: 
///     {{put link to example here}}

contract MeDaoPlatform is TokenController {
    
    uint8 public major_version = 0;
    uint8 public minor_version = 1;
    
    struct Clone {
        address token;
        string url;
    }
    
    struct MeDao {
        address founder;    //Creator of the MeDao
        address controller; //The controller has access to the MeDao functions and should be owned by the founder.
        address vault;      //Tokens generated each week go here
        MiniMeToken Token;  //A cloneable token that represents time (or work) owed by the founder (1 token == 1 second).
        string url;         //A url that links to the founders personal webpage
        uint timestamp;     //Used for calculating when a new week starts
        uint proof_of_work; //Total burned time
        uint total_clones;   //The total number of clones that have been created by this founder
        mapping (uint => Clone) clones;
    }
    
    uint constant ONE_HOUR_IN_WEI = 3600000000000000000000;
    
    MiniMeToken public Prime;
    
    uint public total_founders;
    mapping (uint => address) public founders;
    mapping (address => MeDao) public medaos;
    
////////////////
// Platform Functions
////////////////
    
    function MeDaoPlatform (MiniMeToken prime) {
        Prime = prime;
    }
    
    function deployMeDao (string name) {
        if(medaos[msg.sender].founder != address(0x0)) revert();
        
        total_founders++;
        founders[total_founders] = msg.sender;
        
        address token = Prime.createCloneToken(
            name,
            18,
            'seconds',
            0,
            true
        );
        
        medaos[msg.sender] = MeDao(
            msg.sender,
            msg.sender,
            msg.sender,
            MiniMeToken(token),
            '',
            now,
            0,
            0
        );
    }
    
////////////////
// MeDao Functions
////////////////

    function makePayment (address founder, uint amount, string comment) {
        if(amount == 0) revert();
        
        medaos[founder].Token.destroyTokens(msg.sender,amount);
        medaos[founder].proof_of_work += amount;
        
        Payment_event(founder, msg.sender, amount, comment, block.timestamp);
    }
    
    function startWeek (address founder, uint8 workHours) isNewWeek (founder) {
        if(workHours > 40 || workHours == 0) revert();
        
        medaos[founder].Token.generateTokens(
            medaos[founder].vault, 
            workHours * ONE_HOUR_IN_WEI
        );
        
        NewWeek_event(founder, workHours);
    }
    
    function createClone (
        address founder, 
        string cloneName, 
        string cloneSymbol, 
        string cloneUrl, 
        address cloneController, 
        uint delayInDays
    ) onlyController (founder) {
        uint snapShotBlock = block.number + (4 * 60 * 24 * delayInDays); //4 block per minute, 60 per hour, 24 per day
        address clone = medaos[founder].Token.createCloneToken(
            cloneName,
            18,
            cloneSymbol,
            snapShotBlock,
            true
        );
        
        medaos[founder].total_clones++;
        uint clone_id = medaos[founder].total_clones;
        medaos[founder].clones[clone_id] =  Clone(clone,cloneUrl);
        Controlled(clone).changeController(cloneController);
        
        Clone_event(founder, clone);
    }
    
    function setUrl (address founder, uint clone_id, string newUrl) onlyController (founder) {
        if(clone_id == 0)
            medaos[founder].url = newUrl;
        else
            medaos[founder].clones[clone_id].url = newUrl;
    }
    
    function setVault (address founder, address newVault) onlyController (founder) {
        medaos[founder].vault = newVault;
    }
    
    function setController (address founder, address newController) onlyController (founder) {
        medaos[founder].controller = newController;
    }
    
////////////////
// Token Controller
////////////////

    function proxyPayment(address _owner) payable returns(bool) {
        _owner = _owner; //Needed to compile unused variables...
        revert();
    }

    function onTransfer(address _from, address _to, uint _amount) returns(bool) {
        _from; _to; _amount; //Needed to compile unused variables...
        
        return true;
    }

    function onApprove(address _owner, address _spender, uint _amount) returns(bool) {
        _owner; _spender; _amount; //Needed to compile unused variables...
        
        return true;
    }
    
////////////////
// Internal Functions, Modifiers, and Events
////////////////

    modifier isNewWeek (address founder) {
        var timestamp = medaos[founder].timestamp;
        if (now < timestamp) revert();
        
        if(now < timestamp + 7 days)
            medaos[founder].timestamp = timestamp + 7 days;
        else
            medaos[founder].timestamp = now + 7 days;
            
        _;
    }
    
    modifier onlyController (address founder) {
        if(msg.sender != medaos[founder].controller) revert();
        
        _;
    }
    
    event NewWeek_event(address indexed founder, uint workHours);
    
    event Payment_event(address indexed founder, address indexed sender, uint amount, string comment, uint timestamp);
    
    event Clone_event(address indexed founder, address clone);
}

