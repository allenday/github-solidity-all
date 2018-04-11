/*
*
*
*/
pragma solidity ^0.4.0;


/*
* Test the event system.
*/
contract JavaEventExample {

	uint public eventCount;
	// Start of user code JavaEventExample.attributes
	// End of user code
	
	/*
	* A test event with parameters.
	* 
	* text -
	* index -The index.
	*/
	event Event1(string text,uint index);
	
	
	/*
	* The method that raises the events.
	* 
	* _text -A text for the event.
	*/
	function raiseEvent(string _text) public   {
		//Start of user code JavaEventExample.function.raiseEvent_string
		Event1(_text,eventCount);
		eventCount++;
		//End of user code
	}
	
	// Start of user code JavaEventExample.operations
	// End of user code
}


contract JavaStructExample {
    
    struct TestStruct {
    	uint attribute1;
    	string attribute2;
    }
    
    struct TestStruct1 {
    	string text;
    	uint time;
    	address sender;
    }

	TestStruct public lastStruct;
	uint public structCount;
	uint public structCount1;
	mapping (uint=>TestStruct1)public testStructs1;
	mapping (uint=>TestStruct)public testStructs;
	// Start of user code JavaStructExample.attributes
	// End of user code
	
	
	
	function addStruct(uint _a1,string _a2) public   {
		//Start of user code JavaStructExample.function.addStruct_uint_string
		testStructs[structCount].attribute1 = _a1;
		testStructs[structCount].attribute2 = _a2;
		lastStruct = testStructs[structCount];
		structCount++;
		//End of user code
	}
	
	
	
	function addStruct1(string _text) public   {
		//Start of user code JavaStructExample.function.addStruct1_string
		testStructs1[structCount1].text = _text;
		testStructs1[structCount1].sender = msg.sender;
		testStructs1[structCount1].time = now;
		structCount1++;
		//End of user code
	}
	
	// Start of user code JavaStructExample.operations
	// End of user code
}

/*
* The inheried the event.
*/
contract JavaEventExample1 is JavaEventExample {

	// Start of user code JavaEventExample1.attributes
	// End of user code
	
	/*
	* A second event type.
	*/
	event Event2();
	
	
	/*
	* Raises the Event1 and the Event2.
	*/
	function raiseEvent2() public   {
		//Start of user code JavaEventExample1.function.raiseEvent2
		Event1("test1",1);
		Event2();
		//End of user code
	}
	
	// Start of user code JavaEventExample1.operations
	// End of user code
}

/*
* Shows the basic features.
*/
contract ContractExample {
    enum ContractState { state1,state2,state3 }

	string public text;
	uint public number;
	bool public locked;
	address public creator;
	ContractState public contractState;
	// Start of user code ContractExample.attributes
	// End of user code
	
	modifier testmodifier
	{
	    if(locked) throw;
	    _;
	}
	
	modifier stateModifier(ContractState _state)
	{
	    if(_state!=contractState) throw;
	    _;
	}
	
	
	function ContractExample(string _text) public   {
		//Start of user code ContractExample.constructor.ContractExample_string
		text = _text;
		number = 10;
		creator = msg.sender;
		locked = true;
		//End of user code
	}
	
	
	/*
	* Example for multiple return values.
	* returns
	* _text -
	* _owner -
	* _number -
	* _locked -
	*/
	function contractData() public   constant returns (string _text,address _owner,uint _number,bool _locked) {
		//Start of user code ContractExample.function.contractData
		return (text,creator,number,locked);
		//End of user code
	}
	
	
	/*
	* Change the intern sate of the contract.
	* 
	* _locked -
	*/
	function changeLocked(bool _locked) public   {
		//Start of user code ContractExample.function.changeLocked_bool
		locked = _locked;
		//End of user code
	}
	
	
	/*
	* Change the state, also an example for emum as parameter.
	* 
	* _state -
	*/
	function changeState(ContractState _state) public   {
		//Start of user code ContractExample.function.changeState_ContractState
		contractState = _state;
		//End of user code
	}
	
	
	/*
	* Test method for the 'stateModifier' throws if contractState!=ContractState.state1.
	*/
	function isInState() public  stateModifier(ContractState.state1)  {
		//Start of user code ContractExample.function.isInState
		text = "inState1";
		//End of user code
	}
	
	
	/*
	* Test method for the testmodifer. Throws if locked.
	*/
	function throwIfLocked() public  testmodifier  {
		//Start of user code ContractExample.function.throwIfLocked
		text = "not Locked";
		//End of user code
	}
	
	
	
	function returnStateChange() public  returns (address _creator,uint _time) {
		//Start of user code ContractExample.function.returnStateChange
		locked = !locked;
		_creator = creator;
		_time = block.number;
		//End of user code
	}
	
	
	/*
	* A const function return a single value.
	* returns
	* _text -
	*/
	function returnLast() public   constant returns (string _text) {
		//Start of user code ContractExample.function.returnLast
		return text;
		//End of user code
	}
	
	// getNumber getter for the field number
	function getNumber() constant returns(uint) {
		return number;
	}
	// setNumber setter for the field number
	function setNumber (uint aNumber) {
		number = aNumber;
	}
	
	// Start of user code ContractExample.operations
	// End of user code
}


contract ExampleToken {

	uint256 public totalTokens;
	mapping (address=>uint256)public accountsBalance;
	// Start of user code ExampleToken.attributes
	// End of user code
	
	
	function ExampleToken(uint256 _totalTokens) public   {
		//Start of user code ExampleToken.constructor.ExampleToken_uint256
		totalTokens = _totalTokens;
		accountsBalance[msg.sender] = _totalTokens;
		//End of user code
	}
	
	
	/*
	* Get the total token supply.
	* returns
	* supply -
	*/
	function totalSupply() public   constant returns (uint256 supply) {
		//Start of user code ExampleToken.function.totalSupply
		return totalTokens;
		//End of user code
	}
	
	/*
	* Get the account balance of another account with address _owner.
	* 
	* _owner -
	* returns
	* balance -
	*/
	function balanceOf(address _owner) public   constant returns (uint256 balance) {
		//Start of user code ExampleToken.function.balanceOf_address
		return accountsBalance[_owner];
		//End of user code
	}
	
	/*
	* Send _value amount of tokens to address _to.
	* 
	* _to -
	* _value -
	* returns
	* success -
	*/
	function transfer(address _to,uint256 _value) public  returns (bool success) {
		//Start of user code ExampleToken.function.transfer_address_uint256
//		if(accountsBalance[msg.sender]<_value) 
//			return false;
//		
//		accountsBalance[msg.sender] -=_value;
//		accountsBalance[_to] +=_value;
//		return true;
		return transferFrom(msg.sender,_to,_value);
		//End of user code
	}
	
	/*
	* Send _value amount of tokens from address _from to address _to.
	* 
	* _from -
	* _to -
	* _value -
	* returns
	* success -
	*/
	function transferFrom(address _from,address _to,uint256 _value) public  returns (bool success) {
		//Start of user code ExampleToken.function.transferFrom_address_address_uint256
		if(_from!=msg.sender) 
			return false;
		
		if(accountsBalance[_from]<_value) 
			return false;
		
		accountsBalance[_from] -=_value;
		accountsBalance[_to] +=_value;
		return true;
		//End of user code
	}
	// Start of user code ExampleToken.operations
	// End of user code
}

/*
* An example for the payable modifier. 
* How to send ether to and from the contract.
* The contract stores the value in the amount mapping.
*/
contract JavaPayableExample {

	mapping (address=>uint256)public amounts;
	// Start of user code JavaPayableExample.attributes
	// End of user code
	
	
	/*
	* This send the ether back.
	*/
	function sendBack() public   {
		//Start of user code JavaPayableExample.function.sendBack
		uint a = amounts[msg.sender];
		amounts[msg.sender] = 0;
		msg.sender.send(a);
		//End of user code
	}
	
	
	/*
	* This method accept ether as it has the payable modifier.
	*/
	function recieve() public  payable  {
		//Start of user code JavaPayableExample.function.recieve
		amounts[msg.sender] += msg.value;
		
		//End of user code
	}
	
	
	/*
	* Relay the amount to the _to parameter.
	* 
	* _to -
	* returns
	*  -
	*/
	function relay(address _to) public  payable returns (bool ) {
		//Start of user code JavaPayableExample.function.relay_address
		return _to.send(msg.value);
		
		//End of user code
	}
	
	// Start of user code JavaPayableExample.operations
	// End of user code
}


contract JavaOwnerExample {

	address public owner;
	// Start of user code JavaOwnerExample.attributes
	// End of user code
	
	modifier onlyOwner
	{
	    if(msg.sender!=owner) throw;
	    _;
	}
	
	
	function JavaOwnerExample() public   {
		//Start of user code JavaOwnerExample.constructor.JavaOwnerExample
		owner = msg.sender;
		//End of user code
	}
	
	// setOwner setter for the field owner
	function setOwner (address aOwner) onlyOwner() {
		owner = aOwner;
	}
	
	// Start of user code JavaOwnerExample.operations
	// End of user code
}

