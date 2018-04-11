pragma solidity ^0.4.0;

contract SynchronizeStorage {
    string storedData;
    uint gaslimit;
    uint gasused;
    function setData(string x) {
        storedData = x;
    }
   
    function getGasLimit() constant returns (uint gas){
         gaslimit =  msg.gas;
         return gaslimit;
    }
    function HashOfDB() constant returns (string x) {
        return storedData;
    }
}
