/*
  A simple Contract that stores a number as state variable. Two transaction
  functions and a default call function for the state variable.
  */
pragma solidity ^0.4.2;

/** @title Counter */
contract Counter {
  uint public value;

  function Counter(){
      value=0;
  }
  function increase() external {
    ++value;
  }

  function decrease() external {
    if(value!=0) --value;
  }


}
