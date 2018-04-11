// Copyright (c) 2017 Peter Robinson
//
// This is a simple messaging contract.
//
// Messages can be sent from one address to another address. The messages should be 
// encrypted against the recipients public key. Note that the messages themselves don't 
// need to be signed as the transactions they are contained in are signed by the sender.
//
pragma solidity ^0.4.11;

/** @title Message Engine */
contract MsgEngine {
    struct Message {
        address from;
        uint time;
        string message; 
    }
  
    struct Inbox {
        uint first;           	            // Index of first message;
        uint last;		                    // Index of last message.
        mapping(uint => Message) messages;
        string signedPublicEncrKey;	        // Signed encryption key.
    }
  
    mapping(address => Inbox) public inboxes; // All inboxes.
  

    // Throw an exception to roll-back the transaction if:
    // - the address.send method is called, to send ether to this account.
    // - a function is called which doesn't map to any function on the contract.
   // function() {throw;}
  
  
  uint8 pro;

    function MsgEngine(uint8 proposals) {
        pro = proposals;
    }
  


    /**@dev Send a message to an address.
     * @param _recipient Address to send message to.
     * @param _message Message to put into _recipient's inbox. Consider encrypting messages.

     */
    function sendMsg(address _recipient, string _message) {
        Message memory m = Message({from: msg.sender, time: block.timestamp, message: _message});
        Inbox inbox = inboxes[_recipient];
        inbox.messages[inbox.last] = m;
        inbox.last++;
    }


    /**
     * Get the oldest message.
     */
    function getMsg(address _recipient) constant returns (address, uint, string) {
        Inbox inbox = inboxes[_recipient];
        if (inboxIsEmptyL(inbox)) {
            return (msg.sender, 0, "Empty");
        }
        Message m = inbox.messages[inbox.first];
        return (m.from, m.time, m.message);
    }

  
    /**
     * Delete the oldest message.
     */
    function consumeMsg() {
        Inbox inbox = inboxes[msg.sender];
        if (inboxIsEmptyL(inbox)) {
            // Do nothing if the inbox is already empty.
            return;
        }
        delete inbox.messages[inbox.first];

        inbox.first++;
    }
  

    /**
     * Return true if the inbox is empty.
     */
    function inboxIsEmpty(address _recipient) constant returns (bool) {
        Inbox inbox = inboxes[_recipient];
        return inboxIsEmptyL(inbox);
    }



    /**
     * Return how many messages are in the inbox.
     */
    function inboxSize(address _recipient) constant returns (uint) {
        Inbox inbox = inboxes[_recipient];
        return (inbox.last - inbox.first);
    }

    function setSignedPublicEncKey(string key) {
      inboxes[msg.sender].signedPublicEncrKey = key;
    }


    function getSignedPublicEncKey(address addr) public constant returns (string) {
        string memory pubKey = inboxes[addr].signedPublicEncrKey;
        bytes memory tempEmptyStringTest = bytes(pubKey); // Uses memory
        if (tempEmptyStringTest.length == 0) {
            pubKey = "Empty";
        }
        return pubKey;
    }


    // Private functions.  
    function inboxIsEmptyL(Inbox inbox) constant private returns (bool) {
        return inbox.first == inbox.last;
    }


   
    function check() constant returns (uint) {
        return 5;
    }

}


