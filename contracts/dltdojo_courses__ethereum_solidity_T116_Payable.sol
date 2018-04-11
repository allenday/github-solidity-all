pragma solidity ^0.4.14;
// this, selfdestruct http://solidity.readthedocs.io/en/develop/units-and-global-variables.html?#contract-related
// fallback http://solidity.readthedocs.io/en/develop/contracts.html#fallback-function

contract Foo {
    
  uint storedData;
  
  // the current contract explicitly convertible to address
  address public thisContractDeployAddress = this;
  
  function set(uint x) {
    storedData = x;
  }
  
  //
  // payable keyword
  // function Foo() payable {}
  
  function() payable {}
  
  // destroy the current contract, sending its funds to the given Address
  // Renaming SUICIDE opcode https://github.com/ethereum/EIPs/blob/master/EIPS/eip-6.md
  // selfdestruct - Why are suicides used in contract programming? - Ethereum Stack Exchange
  // https://ethereum.stackexchange.com/questions/315/why-are-suicides-used-in-contract-programming
  function kill(){
      selfdestruct(msg.sender);
  }
}

// TODO
// Foo - create - payable
// FOO - fallback - payable
// Foo - kill