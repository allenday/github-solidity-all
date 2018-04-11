pragma solidity ^0.4.14;
// 
// Bitcoin uses a scripting system for transactions. Forth-like, Script is simple, stack-based, and processed from left to right. It is purposefully not Turing-complete, with no loops.
// https://en.bitcoin.it/wiki/Script
// People often think “loops” are necessary and sufficient to be universal. 
// Ethereum Isn’t Turing Complete and it Doesn’t Matter Anyway 
// https://media.consensys.net/ethereum-isnt-turing-complete-and-it-doesn-t-matter-anyway-625061294d3c
// 
contract FooLoop {

    uint8[10] public intArray;

    function fillArray() returns (uint8[10]){
        uint8 x = 0;                  
        while(x < intArray.length) {
        	intArray[x] = x*x;
        	x++;
        }
        return intArray;
    }
    
    function getSum() constant returns (uint){
        uint sum = 0;
    	for (uint8 i = 0; i < intArray.length; i++) {
    	    sum += intArray[i];
    	}
    	return sum;
    }
}