//Message Board contract, version 1
/**
* Functional Specs:
* hold a buffer of message posted and provide read function by message index
* Only latest 16 messages hold.
* The message's info in buffer inclued who, when and message content. (We will compare the cost with other version)
*/
contract owned {
	address owner;
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
	function kill() onlyOwner {
		selfdestruct(owner);
	}
}

contract MessageBoard is owned
{
	uint8 constant version = 1;
	uint8 constant bufferSize = 16;
	uint64 public count = 0;
	struct Message {
		address from;
		uint time;
		string content;
	}
	Message[] messages;
	//Event when new message posted
	event NewMessage(uint64 index);
	function MessageBoard() {
		owner = msg.sender;
		messages.push(Message(msg.sender, block.timestamp, "É³·¢"));
	}
	//Post a new message
	function post(string message) {
		count++;
		if(count < bufferSize) {
			messages.push(Message(msg.sender, block.timestamp, message));
		}else {
			var index = count % bufferSize;
			messages[index] = Message(msg.sender, block.timestamp, message);
		}
		NewMessage(count);
	}
	
	//Read a message
	function  read(uint64 index) constant returns(address from, uint time, string content) {
		var int_index = index % bufferSize;
		Message m = messages[int_index];
		from = m.from;
		time = m.time;
		content = m.content;
	}
}
