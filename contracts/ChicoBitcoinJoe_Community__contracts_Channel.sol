pragma solidity ^0.4.6;

contract Channel{
    
    string channelName;
    uint block_created;
    
    event Broadcast_event(address sender, string channel, string hash);

    function Channel(string _channel_name){
        channelName = _channel_name;
        block_created = block.number;
    }
    
    function getChannelInfo() constant returns(string,uint){
        return (channelName,block_created);
    }
    
    function broadcast(string hash){
        Broadcast_event(msg.sender,channelName,hash);
    }
}