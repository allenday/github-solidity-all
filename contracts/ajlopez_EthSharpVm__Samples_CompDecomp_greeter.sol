contract greeter {
    /* define variable greeting of the type string */
    string greeting;

    /* this runs when the contract is executed */
    function greeter() public {
        greeting = "Hello, Contract";
    }
    
    function setMessage(string g) {
        greeting = g;
    }

    /* main function */
    function greet() constant returns (string) {
        return greeting;
    }
}

