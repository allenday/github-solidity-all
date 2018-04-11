/* Greeter */
contract mortal {
    address owner;
    function mortal() {
        owener = msg.sender;
    }
    function kill() {
        if (msg.sender == ownter) {
            suicide(owner);
        }
    }
}
contract greeter is mortal {
    string greeting;
    function greeter(string _greeting) public {
        greeting = _greeting;
    }
    function greet() constant returns (string) {
        return greeting;
    }
}
