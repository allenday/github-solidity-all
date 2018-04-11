pragma solidity ^0.4.2;

contract GxTradersInterface {
    function addOrderContract(address gxOrdersAddress) public;

    function add(address newAddress) public;

    function remove(address removedAddress) public;

    function contains(address lookupAddress) public constant returns (bool);

    function coinBalance(address mappedAddress) public constant returns (uint32);

    function dollarBalance(address mappedAddress) public constant returns (int160);

    function setCoinBalance(address mappedAddress, uint32 coinBalance) public;
   
    function setDollarBalance(address mappedAddress, int160 dollarBalance) public;
    
    function addCoinAmount(address mappedAddress, uint32 coinAmount) public;

    function addDollarAmount(address mappedAddress, int160 dollarAmount) public;
}