pragma solidity ^0.4.15;

contract Foo{}
contract Bar{}
contract T01State { uint foo; address bar;}
contract T02InitialUint { uint foo = 5;}
contract T03InitialUint2 { uint foo = 5; uint bar = 36;}
contract T04InitialIntUint { uint foo = 5 ; int bar = -5;}
contract T05InitialInt8 { uint foo = 5 ; uint8 bar = 36;}
contract T06InitialUintString { uint foo = 5; string name="foo";}
contract T07InitialUintHex { uint foo = 5; string name=hex"666F6F";}
contract T08InitialUintAdd { uint foo = 5; uint foo2 = foo+9;}
contract T09InitialUintAddress { uint foo = 5; address bar = 0xdeed;}
contract T10InitialUintMapping { uint foo = 5; mapping (address => uint) balances;}
contract T11InitalEnum { uint foo = 5; enum Action {Left, Right}}
contract T12InitalEnumValue { uint foo = 5; 
  enum Action {Left, Right} 
  Action choice=Action.Left;
}
contract T13InitialStructValue { uint foo = 5; 
   struct Funder { address addr; uint amount;}
   Funder funder= Funder({addr: 0xdeed, amount: 8});
}