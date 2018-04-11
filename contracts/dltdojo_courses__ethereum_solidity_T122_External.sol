pragma solidity ^0.4.14;
// 
// solidity - `external` vs `public` best practices - Ethereum Stack Exchange 
// https://ethereum.stackexchange.com/questions/19380/external-vs-public-best-practices

contract Foo {
    
    // public - all
    // private - only this contract
    // internal - only this contract and contracts deriving from it
    // external - Cannot be accessed internally, only externally.

   function testPublic(uint[20] a) public returns (uint){
         return a[10]*2;
    }
    
    function testPrivate(uint a) private returns (uint){
         return a*2;
    }
    
    function testInternal(uint a) internal returns (uint){
         return a*2;
    }

    function testExternal(uint[20] a) external returns (uint){
         return a[10]*2;
    }
    
    function func1(){
         uint[20] memory x = [uint(1),2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
         testPublic(x);
         testPrivate(5);
         testInternal(5);
         // testExternal(x);
         this.testExternal(x);
    }
}

contract Foo2 is Foo{
     function func1(){
         uint[20] memory x = [uint(1),2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
         testPublic(x);
         // testPrivate(5);
         testInternal(5);
         // testExternal(x);
         this.testExternal(x);
    }
}

contract Bob {

   Foo foo = new Foo();
    
   function testPublic() returns (uint){
       uint[20] memory x = [uint(1),2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
       return foo.testPublic(x);
   }

   function testExternal() returns (uint){
       uint[20] memory x = [uint(1),2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
       return foo.testExternal(x);
   }
    
   function testPrivate() returns (uint){
        // return foo.testPrivate(10);
   }

}