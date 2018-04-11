contract IterableAddressSet {

    function add(address addr) returns (bool) {
        assembly {
                let index := sload(addr)
                let added := not(index) // If offset index for 'addr' isn't 0, add to set.
                jumpi(tag_write, added)
            tag_end:
                mstore(0x0, added)
                return(0x0, 0x20)
            tag_write:
                {
                    let size := sload(0x10)
                    let idxOffset := add(size, 0x11)
                    sstore(addr, idxOffset)
                    sstore(idxOffset, addr)
                    sstore(0x10, add(size, 1)) // Increment by one.
                }
                jump(tag_end)
        }
    }

    function remove(address addr) returns (bool removed) {
        assembly {
                let index := sload(addr)
                let removed := gt(index, 0) // If offset index for 'addr' isn't 0, add to set.
                jumpi(tag_write, removed)
            tag_end:
                mstore(0x0, removed)
                return(0x0, 32)
            tag_write:
                {
                        let size := sload(0x10)
                        let lastOffset := sub(add(size, 0x11), 1)
                        sstore(addr, 0) // Clear storage address 'addr'
                        jumpi(tag_clear, eq(index, lastOffset))
                    tag_swap_addresses:
                        let lastOffsetAddr := sload(lastOffset)
                        sstore(lastOffsetAddr, index)
                        sstore(index, lastOffsetAddr)
                        sstore(lastOffset, 0)
                        jump(tag_finalize)
                    tag_clear:
                        sstore(index, 0)
                    tag_finalize:
                        sstore(0x10, sub(size, 1)) // Reduce size by one

                }
                jump(tag_end)
        }
    }

    function has(address addr) constant returns (bool) {
        assembly {
            mstore(0x0, not(not(sload(addr))))
            return(0x0, 32)
        }
    }

    function size() constant returns (uint) {
        assembly {
            mstore(0x0, sload(0x10))
            return (0x0, 32)
        }
    }

    function all() constant returns (address[]) {
        assembly {
                let size := sload(0x10)
                let i := 0
                mstore(0x0, 0x20) // One-dimensional, dynamic array with 'size' elements.
                mstore(0x20, size)
            tag_loop:
                jumpi(tag_finalize, eq(i, size))
                mstore(add(0x40, mul(i, 32)), sload(add(0x11, i)))
                i := add(i, 1)
                jump(tag_loop)
            tag_finalize:
                return(0x0, add(0x40, mul(size, 32)))
        }
    }

}