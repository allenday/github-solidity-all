pragma solidity ^0.4.14;

// http://remix.ethereum.org/
// http://solidity.readthedocs.io/en/develop/types.html#rational-and-integer-literals

// http://solidity.readthedocs.io/en/develop/frequently-asked-questions.html#how-do-you-represent-double-float-in-solidity
// How do you represent double/float in Solidity?
// This is not yet possible.

contract FooRationalLiterals {
    
    uint a = 987;
    uint b = 10;
    uint b2 = 1e1;
    uint b3 = 1.2e4;
    // ether = 1e18;
    uint public b4 = 1.234 ether;
    uint public c = a / b;
    
    uint public cx = c + 8 ;
    
    //
    // Not yet implemented - FixedPointType
    // Division on integer literals used to truncate in earlier versions, but it will now convert into a rational number, 
    // i.e. 5 / 2 is not equal to 2, but to 2.5.
    //uint c2 = uint(5/2);
    uint public c3 = .5 * 8;
    uint public c4 = uint(a/2);
    
    //
    // Operator + not compatible with types rational_const
    // uint128 c5 = 2.5 + a + 0.5;

    //uint public c6 = uint((987 % 100) / 10);
    uint public c7 = uint((a % 100) / 10);
    
}


// TASK 
// Test FooRationalLiterals
contract FooTest {
    function test(){
        FooRationalLiterals f = new FooRationalLiterals();
        require(f.b4() == 1.233 ether);
    }
}