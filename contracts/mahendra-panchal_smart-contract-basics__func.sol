pragma solidity ^0.4.4;

/** @title func 
*   e.g.
*   check how function work
*   e.g.
*   bytes value 'name' is converted into bytes and then return '3631'
*/
contract func {
    
    uint x;
    
    function getData() returns(uint t){
        t = x;
    }
    
    function setData(uint x) {
        x = x;
    }
    
    bytes2 name = "61";
    
    function getName() returns(bytes2) {
        return name;
    }
    
    function setName(bytes2 myName) {
        name = myName;
    }
    
}