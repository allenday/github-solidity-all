pragma solidity ^0.4.14;
// Application Binary Interface Specification
// http://solidity.readthedocs.io/en/develop/abi-spec.html#application-binary-interface-specification
//

contract Foo {
    
  bytes public calldata;
  
  function hello() returns (bool r){
      calldata = msg.data;
      return true;
  }
  function baz(uint32 x, bool y) returns (bool) {
      calldata = msg.data;
      return x > 32 || y;
  }
  function () payable {}
}

contract FooAbi {
   
   Foo foo;
   
   function FooAbi(address _fooAddr){
       foo = Foo(_fooAddr);
   }
   
   function testHello() returns (bool r){
         return foo.call(bytes4(keccak256("hello()")));
   }
   
   function testFallback() returns (uint fooBalance){
       bytes4 methodId = bytes4(keccak256("helloFallback()"));
       foo.call.value(1.2345 ether)(methodId);
       return foo.balance;
   }
   
   function testBazMethodId() returns (bytes4 MethodId){
       // baz(uint32,bool)
       // 0xcdcd77c0: the Method ID. This is derived as the first 4 bytes of the Keccak hash of the ASCII 
       // form of the signature baz(uint32,bool).
       bytes32 hash = keccak256('baz(uint32,bool)');
       bytes4 methodId = bytes4(hash);
       require(methodId == 0xcdcd77c0);
       return methodId;
   }
   
    function testBazMethod(uint32 x, bool y) returns (bool){
       return foo.baz(x,y);
    }
   
   function () payable {}
}