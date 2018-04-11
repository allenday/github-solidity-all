pragma solidity ^0.4.4;

/** @title construct 
*   one constructer allowed  
*   not overloading possible in contracts
*/  
contract construct {
    
    function construct() {
        // logic
    } 
    
    // throw compile time errors
    function construct(uint m) external {
        // logic
    }
    
}