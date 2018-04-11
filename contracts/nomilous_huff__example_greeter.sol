import "./mortal.sol";

contract greeter is mortal {
    /* define variable greeting of the type string */
    string greeting;

    /* this runs when the contract is executed */
    function greeter(string _greeting) public {
        greeting = _greeting;
    }

    /* main function */
    // function greet() constant returns (string greeting) { // bug: greeting comes up empty
    function greet() constant returns (string theGreeting) {
        return greeting;
    }

    /* constant reply */
    function echo(string value1, string value2) constant returns (string v1, string v2, int16 int1) {
        return (value1, value2, 2);
    }

    /* update greeting */
    event Updated (string newGreeting);

    function update(string value) returns (bool success) {
        greeting = value;
        Updated(greeting);
        return true;
    }
}
