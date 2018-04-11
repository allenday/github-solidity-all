contract Child {

	string public name;
	address public owner; // the originating transaction creator
	address public creator; // the address of the root contract

	function Child(string _name, address _owner) {
		name = _name;
		creator = msg.sender;
		owner = _owner;
	}

}
