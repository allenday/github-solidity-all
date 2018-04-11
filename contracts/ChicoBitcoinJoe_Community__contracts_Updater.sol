pragma solidity ^0.4.6;

import "Owned.sol";

contract Updater is Owned{
    
    ////////////////////////////////////
    // Allow for updating the Updater //
    ////////////////////////////////////
    address newUpdaterAddress;
    string msgHash = '';
    
    function updateUpdater(address _newUpdaterAddress, string _msgHash) isOwner{
        newUpdaterAddress = _newUpdaterAddress;
        msgHash = _msgHash;
    }
    
    function checkForUpdaterUpdate() constant returns (address,string){
        return (newUpdaterAddress,msgHash);
    }
    
    ////////////////////////////////////
    // Generic Updater - with history //
    ////////////////////////////////////
    struct Update{
        string hash;    //It is up to the implementation to handle the hash 
                        //correctly (ipfs vs swarm vs filecoin etc...)
        uint timestamp;
        bool critical;
    }
    
    uint totalUpdates = 0;
    mapping (uint => Update) updates;
    
    function getTotalUpdates() constant returns(uint){
        return totalUpdates;
    }
    
    function newUpdate(string _updateAddress, bool _critical) isOwner{
        updates[++totalUpdates] = Update(_updateAddress,block.timestamp,_critical);
    }
    
    function getUpdateByID(uint id) constant returns(string,uint,bool){
        string addr = updates[id].hash;
        uint timestamp = updates[id].timestamp;
        bool critical = updates[id].critical;
        return (addr,timestamp,critical);
    }
    
    function getLatestUpdate() constant returns(string,uint,bool){
        return getUpdateByID(totalUpdates);
    }
}