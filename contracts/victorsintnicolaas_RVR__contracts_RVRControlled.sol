pragma solidity ^0.4.2;

contract RVRControlled {

   address owner;

  //addres owner;
	event notOwner(address notTheOwner);

    modifier isOwner {
    	if(msg.sender != owner) {
    		notOwner(msg.sender);
    		throw;
    	}
    	_;
    }

	function remove(address owner) isOwner {
        selfdestruct(owner);
    }

}
