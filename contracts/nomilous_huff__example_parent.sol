import "./child.sol";

contract Parent {
	struct ChildDef {
		string name;
		address owner;
		address child;
	}
	mapping (address => ChildDef) public children;
	event Created(string name, address owner, address child);

  /* Call to spawn a new instance of Child contract */
	function spawnChild(string name) {
		var child = new Child(name, msg.sender);
		children[child] = ChildDef(name, msg.sender, child);

		// Event appears in transaction log
		Created(name, msg.sender, child);
	}
}
