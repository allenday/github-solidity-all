pragma solidity ^0.4.4;

contract HelloWorld {
    
    bytes m = "mahendra panchal mahendra amasdfadsf asdf asdf asdf asdf asdfa sdfas dfas dfasdf asdfasdf";
    
    bytes1 m0 = "Y";
    
    bytes2 m01 = "YN";
    
    bytes8 m1 = "MAHE_MAH";
    
    bytes16 m2 = "One_Two_Three_4_";
    
    bytes30 m3 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ____";
    
	string message = "hello mahendra";

	function getMessage() checkHellStatus returns(string) {
		return message;
	} 
    
    bool isHell = true;
    
    modifier checkHellStatus() {
        if(isHell) {
            throw;
        }
      _;  
    }
    
    //modifier onlySeller() { // Modifier
      //  if (msg.sender != seller) throw;
      //    _;
    //}
    
}