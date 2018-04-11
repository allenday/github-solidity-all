pragma solidity ^0.4.7;
contract Fibonacci {
    uint[] public numbers = [1, 1];
    
    function getNumber(uint position) returns (uint number,uint length) {
        if (position == 0) {
            return (0, numbers.length);
        }
        uint index = position-1;
        if (index < numbers.length) {
             length = numbers.length;
             number = numbers[index];
             return;
        }
        for (uint i = numbers.length; i<=index; i++) {
            numbers.push(numbers[i-1] + numbers[i-2]);
        }
        number = numbers[index];
        length = numbers.length;
        return;
    }
    
    function() payable {
        
    }

   function value() constant returns(uint) {
       return this.balance;
   }
   
 }