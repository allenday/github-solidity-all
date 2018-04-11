pragma solidity ^0.4.2;

contract GxOwnedInterface {
	// abstract functions
	function isOwner(address accountAddress) constant returns (bool);
    function addOwner(address accountAddress);
    function removeOwner(address accountAddress);
}