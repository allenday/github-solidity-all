contract smart {
    /* Define variable owner of the type address*/
    address owner;

    /* this function is executed at initialization and sets the owner of the contract */
    function smart() {
        owner = msg.sender;
    }

    /* Function to recover the funds on the contract */
    function destroy() {
        if (msg.sender == owner) suicide(owner);
    }
}

contract greeter is smart {
    /* define variable greeting of the type string */
    string greeting;

    /* this runs when the contract is executed */
    function greeter(string _greeting) public {
        greeting = _greeting;
    }

    /* main function */
    function greet() constant returns (string) {
        return greeting;
    }
}