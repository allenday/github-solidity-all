pragma solidity ^0.4.16;
// Release Version 0.4.16 · ethereum/solidity https://github.com/ethereum/solidity/releases/tag/v0.4.16
// We split the constant keyword for functions into 
// pure (neither reads from nor writes to the state) and 
// view (does not modify the state).
// They are not enforced yet, but will most likely make use of the the new STATIC_CALL feature after Metropolis.

contract FooTest {
    
    Foo foo = new Foo();
    
    function testPure(){
        uint a = foo.pureFunc();
        require(a == 9);
    }
    
    function testView(){
        uint a = foo.viewFunc(); 
        require(a == 9);
    }
}

contract Foo {
    
    uint x  = 9 ;
    function pureFunc() pure returns (uint){
      return x;
    }
    
    function viewFunc() view returns (uint){
      return x;
    }
    
    function () payable {}
}
