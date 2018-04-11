pragma solidity ^0.4.14;
// 
// http://remix.ethereum.org/
// Everything on the Ethereum blockchain is public.
// 

contract Foo {
    
    uint public a = 10 ;
    
    uint private b = 8 ;
    
    function set(uint _b){
        b = _b;
    }
}

contract FooTest {
    
    function testPrivacy() {
        Foo foo = new Foo();
        require(foo.a() == 10);
    }
    
    // b ?
}

//
// 1. initial state b
//
// Foo.Create - Launch debuger
// b = 8 => PUSH1 08
//
// rinkeby
// contract https://rinkeby.etherscan.io/address/0xcbb3595724bd39f75986dd8e3560971ac1b20ade
// Foo.Create Tx https://rinkeby.etherscan.io/tx/0x7cf77a2fd186bfd73a38e7368e37147c4964c72e8ff734ca06106bd80afbaabc
// remix debug http://rinkeby.etherscan.io/remix?txhash=0x7cf77a2fd186bfd73a38e7368e37147c4964c72e8ff734ca06106bd80afbaabc


// 2. find state b in function set()
//
// foo.set(9) - Launch debuger
// Functions :  0dbe671f a() 60fe47b1 set(uint256)
// calldata : 0x60fe47b10000000000000000000000000000000000000000000000000000000000000009
// instructions : SSTORE
// stack 0x1 0x9
// 
// rinkeby 
// https://rinkeby.etherscan.io/tx/0x197a28bc83aed1f817e81edbf6021a5541b350dd38129a92f1874e7184224f1e

// 3. find state b in Foo At Address
// Foo At Address
// a() Launch debugger
// Storagecompletely loaded
// key: 0x0000000000000000000000000000000000000000000000000000000000000001
//
// rinkeby 
// contract https://rinkeby.etherscan.io/address/0xcbb3595724bd39f75986dd8e3560971ac1b20ade
// 


// TODO
// (JavaScriptVM/Rinkeby) set a new number and find it.