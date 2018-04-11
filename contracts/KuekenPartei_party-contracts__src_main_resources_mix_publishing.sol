/*
*
*(c) 2016 KUEKeN
* Urs Zeidler
*
*/
pragma solidity ^0.4.1;

import "./basics.sol";


contract MessagePublisher {
	
	/*
	* Publish the message to the blog.
	* 
	* message -The message to send.
	* hash -The hash of the message.
	* er -The external resource of the message.
	*/
	function publishMessage(string message,string hash,string er) public  ;
}

/*
* A Short blog can save messages on the blockchain.
*/
contract ShortBlog is Manageable {
    /*
    * A message in the blog.
    */
    struct Message {
    	string message;
    	uint date;
    	uint id;
    	address sender;
    	uint blockNumber;
    	string hashValue;
    	string externalResource;
    }

	uint public messageCount;
	uint public lastMessageDate;
	string public name;
	mapping (uint=>Message)public messages;
	// Start of user code ShortBlog.attributes
	//TODO: implement
	// End of user code
	
	/*
	* Called when a new message is posted.
	* 
	* message -The message.
	* messageId -
	* messageSender -The sender of the message.
	* messageHashValue -The hash of the message.
	* externalResource -The external resource (a link) to the message. 
	*/
	event NewMessage(string message,uint messageId,address messageSender,string messageHashValue,string externalResource);
	
	
	function ShortBlog(string _name) public   {
		//Start of user code ShortBlog.constructor.ShortBlog_string
		//super();
		name = _name;
		//End of user code
	}
	
	
	/*
	* Send a message to the blog,
	* 
	* message -The message as string.
	* hash -The hash of the external source.
	* er -The link to the message.
	*/
	function sendMessage(string message,string hash,string er) public  onlyManager()  {
		 
		
		//Start of user code ShortBlog.function.sendMessage_string_string_string
		 messages[messageCount].message=message;
		 messages[messageCount].id=messageCount;
		 messages[messageCount].date=now;
		 messages[messageCount].sender=msg.sender;
		 messages[messageCount].externalResource = er;
		 messages[messageCount].hashValue = hash;
		 messages[messageCount].blockNumber=block.number;
		 NewMessage(message,messageCount,msg.sender,hash,er);
		 lastMessageDate= now;
		 messageCount++;
		//End of user code
	}
	
	// Start of user code ShortBlog.operations
	//TODO: implement
	// End of user code
}

/*
* The registry create new blogs.
*/
contract BlogRegistry is Manageable {

	uint public blogCount;
	mapping (uint=>ShortBlog)public blogs;
	// Start of user code BlogRegistry.attributes
	//TODO: implement
	// End of user code
	
	
	event NewBlog(uint index,string name,address blogAddress);
	
	
	/*
	* Register a blog under a name.
	* returns 0 for ok and 1 else.
	* 
	* _name -The name of the blog.
	* returns
	*  -
	*/
	function registerBlog(string _name) public  onlyManager() returns (ShortBlog ) {
		
		//Start of user code BlogRegistry.function.registerBlog_string
		ShortBlog sb = new ShortBlog(_name);
		sb.addManager(msg.sender);
		blogs[blogCount] = sb;
		NewBlog(blogCount,_name,sb);
		blogCount++;
		return sb; 
		//End of user code
	}
	
	// Start of user code BlogRegistry.operations
	//TODO: implement
	// End of user code
}

