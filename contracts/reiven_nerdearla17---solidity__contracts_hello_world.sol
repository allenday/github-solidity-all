pragma solidity ^0.4.10;

contract HelloWorld {

    /* Create a string variable */
    string foo;

    /* Constructor: we set the mandatory 'Hello World' message */
    function HelloWorld() {
        foo = 'Hello World!';
    }

    /* Change the variable value */
    function set_foo(string new_foo) {
        foo = new_foo;
    }

    /* Function to get the variable value */
    function get_foo() constant returns (string) {
        return foo;
    }
}
