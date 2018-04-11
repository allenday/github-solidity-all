/* Obligatory hello world app - taken from Ethereum website */
contract mortal {
	/* owner of the contract */
	address owner;

	/* initialisation - set owner */
	function mortal() { owner = msg.sender; }

	/* owner can kill the contract */
	function kill() { if (msg.sender == owner) suicide(owner); }
}

contract greeter is mortal {
	/* define what the greeter will say */
	string greeting;

	/* initialising - set the greeting */
	function greeter(string _greeting) public {
		greeting = _greeting;
	}

	/* the main function */
	function greet() constant returns (string) {
		return greeting;
	}
}
