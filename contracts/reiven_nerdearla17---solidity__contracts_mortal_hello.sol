pragma solidity ^0.4.10;


contract mortal {
    /* Define variable owner of the type address*/
    address owner;

    /* Sets the owner of the contract */
    function mortal() {
        owner = msg.sender;
    }

    /* Function to recover the funds on the contract */
    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }
}


contract Mortal_HelloWorld is mortal{

    string foo;

    /* Log every change in an event */
    event LogFooChanges(address changed, string new_foo);

    function Mortal_HelloWorld() {
        foo = 'Hello World!';
    }

    function set_foo(string new_foo) {
        foo = new_foo;
        /* Send the information to the Event */
        LogFooChanges(msg.sender, new_foo);
    }

    function get_foo() constant returns (string) {
        return foo;
    }
}
