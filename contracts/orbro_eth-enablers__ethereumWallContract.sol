contract EtheriumWall {

    struct Message {
        uint donationAmount;
        uint likeCount;
        mapping ( address =&gt; bool ) likers;
        uint giftedAmount;
        address etherAddress;
        uint timestamp;
        string message;
        bool hasBeenMostGenerous;
    }

    address public owner;

    // Category of this wall:
    string public category;

    // Message storage:
    Message[] public messages;
    uint public mostGenerous;
    uint public mostLikedMessage;
    uint public messageCount;

    // Events:
    event newMessage(uint indexed messageId);
    event newLike(uint indexed messageId, address liker, uint giftAmount);
    event newMostGenerous(uint indexed messageId);

    // Public decentralized message board with donations and pay-to-promote
    function EtheriumWall(string newCategory) {
        category = newCategory;
        owner = msg.sender;
    }

    function() {
        // Catcher function, we'll presume that this kind user is donating if they have
        // sent Ether:
        if(msg.value == 0) throw;

        sendMessage("_I donated!_");
    }

    function sendMessage(string message) {
        // Restrict message length to 300 metric kilobytes
        if(bytes(message).length &gt; 300000) throw;

        // Get the ID of the new message to insert
        messageCount = messages.length;
        messages.length += 1;

        // Set up our new message.
        messages[messageCount].etherAddress = msg.sender;
        messages[messageCount].donationAmount = msg.value;
        messages[messageCount].message = message;
        messages[messageCount].timestamp = block.timestamp;

        // Fire event
        newMessage(messageCount);

        // Was this person more generous than the most generous person ever?
        if(msg.value &gt; messages[mostGenerous].donationAmount) {
            messages[messageCount].hasBeenMostGenerous = true;
            mostGenerous = messageCount;
            newMostGenerous(mostGenerous);
        }
    }

    function like(uint messageId) {
        // Someone liked a message!

        // Did they already like this?
        if(messages[messageId].likers[msg.sender]) throw;

        // Was the message ID valid?
        if(messageId &gt;= messages.length) throw;

        messages[messageId].likers[msg.sender] = true;
        messages[messageId].likeCount++;

        // Is this message now the most liked message ever?
        if(messages[messageId].likeCount &gt; messages[mostLikedMessage].likeCount) {
            mostLikedMessage = messageId;
        }

        // Did the user send some ether as a gift?!
        if(msg.value &gt; 0) {
            messages[messageId].giftedAmount += msg.value;
            if(!messages[messageId].etherAddress.send(msg.value)) throw;
        }

        newLike(messageId, msg.sender, msg.value);
    }

    // Only the owner of the site can do certain things
    modifier admin { if (msg.sender == owner) _ }

    // Lets the owner withdraw their precious money
    function collectDonations(uint amount, address recipient) admin {
        if(!recipient.send(amount)) throw;
    }

    // Allows the current owner to transfer it to someone new
    function transferOwnership(address newOwner) admin {
        owner = newOwner;
    }
}