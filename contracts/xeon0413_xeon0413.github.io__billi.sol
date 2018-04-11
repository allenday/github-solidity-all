pragma solidity ^0.4.11; 
 
contract billi {
    
    address sender;
    address receiver;
    string amount;
 
    function sendMsg(address aim, string from_text) {
 
        sender = msg.sender;
        receiver = aim;
        amount = from_text;
 
    }
 
    function getMsg() constant returns (address, string, bool) {
        
        return (receiver == msg.sender) ? (sender, amount, true) : (msg.sender, "", false);
 
    }
    
}