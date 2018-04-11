pragma solidity ^0.4.2;
// In computer programming, a directive pragma (from "pragmatic")
// is a language construct that specifies how a compiler
// (or assembler or interpreter) should process its input.

contract HelloWorld{

    // variable to store greeting text
    string public greeting;
    uint public numberOfChanges = 0;

    // This is the constructor whose code is
    // run only when the contract is created.
    // Recommended practice is to make constructors
    // without constructor parameters
    function HelloWorld(string _greeting){
        greeting = _greeting;
    } // end of constructor

    event GreetingChanged(string NewGreetingText, uint NewGreetingNumber);
    //
    function changeGreeting(string _greeting){
        greeting = _greeting;
        numberOfChanges++;
        GreetingChanged(_greeting, numberOfChanges);
    } // end of changeGreeting

}
