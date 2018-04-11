pragma solidity ^0.4.13;


contract Randomized {

    struct Key {
        uint entryBlockNumber;
        bytes32 publicKey;
    }

    mapping (address => Key[]) keys;

    function setKey(bytes32 publicKey) public {
        Key[] storage senderKeys = keys[msg.sender];
        require(senderKeys.length == 0 || senderKeys[senderKeys.length-1].entryBlockNumber < block.number);
        senderKeys.push(Key(block.number, publicKey));
    }

    function validate(uint seedBlockNumber, bytes32 seed, address sender, bytes32 crypted, bytes32 result) constant public returns (bool) {
        if (keccak256(crypted, seed) != result) 
            return false;
        Key memory key = findKey(keys[sender], seedBlockNumber);
        if (key.entryBlockNumber >= seedBlockNumber) 
            return false;
        return keccak256(seed) == privatized(crypted, key.publicKey);
    }

    function findKey(Key[] addressKeys, uint seedBlockNumber) constant private returns (Key) {
        uint x = addressKeys.length;
        //TODO: These are in order => use binary search
        while (x > 0) {
            x -= 1;
            if (seedBlockNumber > addressKeys[x].entryBlockNumber) {
                return addressKeys[x];
            } 
        }
        return Key(0, 0x0);
    }

    function privatized(bytes32 crypted, bytes32 publicKey) constant private returns (bytes32) {
        // Waiting for https://github.com/ethereum/EIPs/pull/198
        // And specifically this from geth (and same from other clients): 
        // https://github.com/ethereum/go-ethereum/blob/104375f398bdfca88183010cc3693e377ea74163/core/vm/contracts.go#L56
        // For now using just a simple bitwise xor to get the bidirectional mapping for testing
        return crypted ^ publicKey;
    }

    function modexp(bytes memory _base, bytes memory _exp, bytes memory _mod) constant returns(bytes) {
    
        uint256 bl = _base.length;
        uint256 el = _exp.length;
        uint256 ml = _mod.length;
        assembly {
            // Free memory pointer is always stored at 0x40
            let freemem := mload(0x40)
            
            // arg[0] = base.length @ +0
            mstore(freemem, bl)
            
            // arg[1] = exp.length @ +32
            mstore(add(freemem,32), el)
            
            // arg[2] = mod.length @ +64
            mstore(add(freemem,64), ml)
            
            // arg[3] = base.bits @ + 96
            // Use identity built-in (contract 0x4) as a cheap memcpy
            let retval := call(450, 0x4, 0, add(_base,32), bl, add(freemem,96), bl)
            
            // arg[4] = exp.bits @ +96+base.length
            let size := add(96, bl)
            retval := call(450, 0x4, 0, add(_exp,32), el, add(freemem,size), el)
            
            // arg[5] = mod.bits @ +96+base.length+exp.length
            size := add(size,el)
            retval := call(450, 0x4, 0, add(_mod,32), ml, add(freemem,size), ml)
            
            // Total size of input = 96+base.length+exp.length+mod.length
            size := add(size,ml)
            // Invoke contract 0x5, put return value right after mod.length, @ +96
            retval := call(sub(gas, 1350), 0x5, 0, freemem, size, add(96,freemem), ml)
            
            // Prepare return value (offset, length, bits) by reusing mod.length @ +64
            freemem := add(32,freemem)
            
            // Store offset to array (32) @ +0. Note that mod.length is now at @ +32
            mstore(freemem, 32)
            
            // Total size of output = 64+mod.length
            return(freemem, add(64,ml))
        }
    }

}