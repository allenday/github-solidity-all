pragma solidity ^0.4.14;

// solidity - Difference between require and assert and the difference between revert and throw - Ethereum Stack Exchange 
// https://ethereum.stackexchange.com/questions/15166/difference-between-require-and-assert-and-the-difference-between-revert-and-thro/
// solidity 0.4.10 require vs throw - Ethereum Stack Exchange https://ethereum.stackexchange.com/questions/13337/solidity-0-4-10-require-vs-throw
// throw is now (v0.4.13) deprecated, 
// use require for external input checks, 
// assert for internal status checks and revert to show an explicit error to the user.

contract Foo {
    
  uint x = 1;
  
  function mul2Throw(uint amount) returns (uint) {
    x += amount;
    if (amount < 10) {
      throw;
    }
    return amount*2;
  }
  
  function mul2Revert(uint amount) returns (uint) {
      x += amount;
      if (amount < 10){
          revert();
      }
      return amount*2;
  }
  
  // require(false) compiles to (0xfd), which is currently invalid, but after Metropolis will become REVERT
  // meaning it will refund the remaining gas, and return a value (useful for debugging).
  // 
  function mul2Require(uint amount) returns (uint) {
    x += amount;
    require(amount > 10); // especially towards the beginning of a function.
    //
    //
    //
    //
    return amount*2;
  }
  
  // assert(false) compiles t 0xfe, which is an invalid opcode, using up all remaining gas, and reverting all changes.
  function mul2Assert(uint amount) returns (uint) {
    x += amount;
    //
    //
    //
    //
    assert(amount > 10); // especially towards the end of your function.
    return amount*2;
  }
  
}