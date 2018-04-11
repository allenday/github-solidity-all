pragma solidity ^0.4.14;

// arrays http://solidity.readthedocs.io/en/develop/types.html#arrays
// 
contract Foo {

    uint[5] public fooIntArray;
    address[10] public fooAddressArray;
    uint[] public fooIntArrayDynamic;
    // As an example, an array of 5 dynamic arrays of uint is uint[][5] (note that the notation is reversed when compared to some other languages). 
    uint[][5] aArrayOf5DynamicArrays;
    uint[3] public fooIntLiteral = [uint(1), 2, 3];
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    function Foo(){
        fooIntArray[0] = 100;
        fooIntArray[2] = 200;
        fooAddressArray[0] = this;
        fooAddressArray[3] = msg.sender;
        
        // error 
        // fooIntArrayDynamic[0] = 99;
        fooIntArrayDynamic.push(99);
        
        balances[this] = 100 ether;
        balances[msg.sender] = 200 ether;
        balances[address(0)] = 999 ether;
    }
    
    // Forced data location:
    //     parameters (not return) of external functions: calldata
    //     state variables: storage
    // Default data location:
    //     parameters (also return) of functions: memory
    //     all other local variables: storage
    function memoryArray(uint len) {
        uint[] memory a = new uint[](7);
        bytes memory b = new bytes(len);
        // Here we have a.length == 7 and b.length == len
        a[6] = 8;
    }
    
    // It is possible to mark arrays public and have Solidity create a getter. 
    // The numeric index will become a required parameter for the getter.
    
    // Due to limitations of the EVM, it is not possible to return dynamic content from external function calls. 
    // The function f in contract C { function f() returns (uint[]) { ... } } will return something if called from web3.js, 
    // but not if called from Solidity.
   
    function getAddressArray() returns (address[10]){
        return fooAddressArray;
    }
    
    function getIntArrayDynamic() returns (uint[]){
        return fooIntArrayDynamic;
    }
    
    function changeFooIntArrayDynamicSize(uint newSize) {
        // if the new size is smaller, removed array elements will be cleared
        fooIntArrayDynamic.length = newSize;
    }
    
    function clearFooArray() {
        // these clear the arrays completely
        delete fooIntArray;
    }
}

contract FooUser {
    Foo foo;
    address[10] public fooUserAddrArray;
    function FooUser(address _fooAddress){
        foo = Foo(_fooAddress);
    }
    
    // The only workaround for now is to use large statically-sized arrays.
    function testFooArray(){
        fooUserAddrArray = foo.getAddressArray(); 
        // error 
        // uint[] intArray = foo.getIntArrayDynamic();
    }
}
