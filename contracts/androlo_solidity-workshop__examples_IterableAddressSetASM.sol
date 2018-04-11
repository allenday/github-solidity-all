contract AddressSet {

    // uint constant SIZE_ADDRESS = 0x10;
    // uint constant STORAGE_OFFSET = 0x11;

    function add(address addr) returns (bool added) {
        assembly {  // [garbage, addr, added]
                swap1
                dup1
                sload           // Load current index.
                not             // Will be 1 if storage[addr] == 0, which means 'addr' should be added.
                dup1
                tag_write
                jumpi
            tag_end:            // [addr, added]
                0x0
                mstore
                0x20
                0x0
                return
            tag_write:          // [addr, added]
                swap1           // put 'addr' on top.
                0x10            // Load current set size
                sload
                dup1            // Add 1 to set size and store it
                1
                add
                0x10
                sstore
                0x11            // Calculate new storageAddress (index + offset)
                add
                dup1            // storage[addr] = storageAddress
                dup3
                sstore
                sstore          // storage[storageAddress] = addr
                tag_end         // done
                jump
        }
    }

    function remove(address addr) returns (bool removed) {
        assembly {  // [garbage, addr, added]
                swap1
                dup1
                sload           // [addr, offsetIndex]
                0
                dup2
                gt              // Will be 1 if offsetIndex > 0, which means 'addr' will be removed.
                dup1
                tag_write
                jumpi
            tag_end:            // 'removed' on the top
                0x0
                mstore
                0x20
                0x0
                return
            tag_write:          // [addr, offsetIndex, removed]
                swap2
                0               // Clear storage[addr]
                swap1
                sstore          // Next [removed, offsetIndex]
                0x10            // check if lastOffsetIndex == offsetIndex
                sload           // current size
                dup1            // store for later
                0x11            // address offset for the set
                add
                1
                swap1
                sub             // [removed, offsetIndex, size, lastOffsetIndex]
                dup3
                dup2
                eq              // lastOffsetIndex == offsetIndex
                tag_clear
                jumpi
            tag_swap_addresses: // [removed, offsetIndex, size, lastOffsetIndex]
                dup1
                sload           // Next [removed, offsetIndex, size, lastOffsetIndex, addressAtLastOffsetIndex]
                dup1            // storage[offsetIndex] = addressAtLastOffsetIndex
                dup5
                sstore
                dup4            // storage[addressAtLastOffsetIndex] = offsetIndex
                swap1
                sstore          // [removed, offsetIndex, size, lastOffsetIndex]
                0               // storage[lastOffsetIndex] == 0
                swap1
                sstore
                pop
                tag_finalize
                jump
            tag_clear:          // [removed, offsetIndex, size, lastOffsetIndex]
                pop
                swap1
                0          // storage[offsetIndex] = 0
                swap1           // swap with 'offsetIndex'
                sstore          // Next [removed]
            tag_finalize:       // [removed, size]
                1               // Sub 1 from current size and overwrite
                swap1
                sub
                0x10
                sstore
                tag_end         // done
                jump
        }
    }

    function has(address addr) returns (bool has) {
        assembly {  // [garbage, addr, has]
                swap1
                sload       // Load the index at 'addr'
                not         // turn it to 0 or 1
                not
                0x0
                mstore
                0x20
                0x0
                return
        }
    }

    function size() constant returns (uint size) {
        assembly {
                0x10
                sload
                0x0
                mstore
                0x20
                0x0
                return
        }
    }

}
