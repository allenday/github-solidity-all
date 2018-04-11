pragma solidity ^0.4.6;

import "Channel.sol";

contract SharePlatform {
    
    event NewChannel_event(string channelName);
    
    uint total_channels = 0;
    mapping (uint => string) channelIndex;
    mapping (string => address) channelList;

    function createChannel(string channelName){
        if(channelList[channelName] == 0){
            total_channels++;
            channelIndex[total_channels] = channelName;
            channelList[channelName] = new Channel(channelName);
            
            NewChannel_event(channelName);
        }
    }
    
    function getTotalchannels() constant returns(uint){
       return total_channels;
    }
    
    function getChannelName(uint index) constant returns(string){
       return channelIndex[index];
    }
    
    function getChannelAddress(string channelName) constant returns(address){
        return channelList[channelName];
    }
}