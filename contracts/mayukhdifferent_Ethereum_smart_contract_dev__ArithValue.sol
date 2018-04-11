pragma solidity ^0.4.11;
// define new contract
contract ArithValue{
	uint number;
	function ArithValue(){  //constructor function with default value
		number = 100;
	}
// constructor function	to set new value
	function setNumber(uint theValue){
	    number = theValue;
	}
// constructor function	to fetch the new value	
	function fetchNumber() constant returns (uint) {
		return number;
	}
// constructor function	to increment by one	
	function incrementNumber(){
	    number=number + 1;
	}
// constructor function	to decrement by one	
	function decrementNumber(){
	    number=number - 1;
	}
}