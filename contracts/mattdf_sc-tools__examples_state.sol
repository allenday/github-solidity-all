contract Test {
	int store;
	address creator;

	event StoreEvent (
		int store,
		int store16
	);
	event ShortStore (
		int store
	);

	function Test(int a) {
		creator = msg.sender;
		store = a;
	}

	function multStore(int a) constant returns(int) {
		return a*store;
	}

	function setStore(int a) {
		store = a;
		StoreEvent(a, a*16);
		ShortStore(a);
	}

	function getStore() constant returns(int){
		return store;
	}
}
