pragma solidity ^0.4.8;


contract NamedEntity {
	function symbol() public constant returns (string symbol);

	function name() public constant returns (string name);
}
