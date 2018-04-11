pragma solidity ^0.4.10;

//the very second example
contract Example2 {
	struct Account {
		string addr;
		uint amount; //default is 256bits
	}

	uint counter;
	mapping (uint => Account) accounts;

    function Example2(string addr) {
        accounts[counter++] = Account(addr, 42);
    }

    function get(uint nr) constant returns (string) {
        return accounts[nr].addr;
    }
}
