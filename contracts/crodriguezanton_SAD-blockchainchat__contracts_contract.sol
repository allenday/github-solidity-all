pragma solidity ^0.4.10;

contract owned {
    function owned() { owner = msg.sender; }
    address owner;
}

contract Message {

    User sender;
    string content;
    uint timestamp;

    function Message(User _sender, string _content, uint _timestamp){
        sender = _sender;
        content = _content;
        timestamp = _timestamp;
    }

    function getContent() constant returns(string){
        return content;
    }

    function getTimestamp() constant returns(uint){
        return timestamp;
    }

    function getSender() constant returns(User){
        return sender;
    }

}

contract Database {
    User[] users;
    Chat[] chats;

    function addUser(User _user) {
        users.push(_user);
    }

    function addChat(Chat _chat) {
        chats.push(_chat);
    }

    function getChats() constant returns(Chat[]){
        return chats;
    }

    function getUsers() constant returns(User[]){
        return users;
    }
}

contract User is owned {
    string name;
    Chat[] chats;

    function User(string _name) {
        name = _name;
    }

    function addChat(Chat _chat) {
        chats.push(_chat);
    }

    function getName() constant returns(string){
        return name;
    }

    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }

    function isOwner() constant returns(bool){
        return msg.sender == owner;
    }
}

contract Chat {

    string name;
    User[] recipients;
    Message[] messages;

    function Chat(User sender, User recipient) {
        recipients.push(sender);
        recipients.push(recipient);
    }

    function setName(string _name){
        name = _name;
    }

    function getRecipients() constant returns(User[]) {
        return recipients;
    }

    function getMessages() constant returns(Message[]) {
        return messages;
    }

    function addMessage(User _sender, string _content, uint _timestamp) {
        messages.push(new Message(_sender, _content, _timestamp));
    }
}
