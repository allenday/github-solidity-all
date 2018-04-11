pragma solidity ^0.4.15;
import "jsmnsol-lib/JsmnSolLib.sol";

contract GreenChain {
	struct GreenBlock {
		uint uniqueID;
    	address owner;
    	string name;
    	uint quantity;
		mapping (string => bytes32) lca;
	}

  	struct GreenBlockBlueprint {
		mapping (uint => GreenBlock) parts;
  	}

  	uint blkid;
  	mapping (uint => GreenBlock) inventory;
	mapping (string => bytes32) emptyLCA;


	function GreenChain() {
		blkid = 0;
	}

  	function addBlock(string name, uint quantity, string blk) {
  		// addBlock(string name, uint quantity, GreenBlockBlueprint blk)
  		blkid = blkid++;
  		GreenBlock memory gb = GreenBlock(blkid, msg.sender, name, quantity);
  		

	  	mapping (string => bytes32) aggLCA = emptyLCA;
  		for (uint same3 = 0; same3 < 1; same3++) {
        }
  		inventory[blkid] = gb;
  	}

  	function fetchAllBlocks() constant returns (string) {
  		// this actually returns (mapping (uint => GreenBlock))
    	return "inventory";
  	}

  	function fetchBlocks(address owner) constant returns (string) {
  		// this actually returns (mapping (uint => GreenBlock))
    	return "inventory";
  	}
}
