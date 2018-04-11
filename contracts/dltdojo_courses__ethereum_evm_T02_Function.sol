pragma solidity ^0.4.15;

contract Foo { uint foo = 5;}
contract T01Public { uint public foo = 5;}
contract T02Get {uint foo = 5;  function get() constant returns (uint) {return foo;}}
contract T03GetAdd {uint foo = 5;  function get() constant returns (uint) {return foo+5;}}
contract T04GetParamMul {function get(uint a) constant returns (uint) {return a*5;}}
contract T05Get2Functions {
    function getMul(uint a) constant returns (uint) {return a*5;}
    function getAdd(uint a) constant returns (uint) {return a+5;}
}