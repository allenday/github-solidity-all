pragma solidity ^0.4.18;

/*
   a simple introduction smart contract
   with an example of how to set and get values in Solidity
*/

contract Hello {
    string greeting;
    
    // setter function
    function setGreeting(string s) {
        greeting = s;
    }
    
    // getter function
    function getGreeting() view returns (string s) {
        s = greeting;
    }
}
