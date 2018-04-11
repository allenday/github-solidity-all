/*
 * This is a third-party implementation of a SequenceArray, extracted into
 * a separate contract from Eris's `hello-eris` example repository.
 * SOURCE: https://github.com/eris-ltd/hello-eris/blob/master/contracts/DealManager.sol
 */

contract SequenceArray {
    // main map
    mapping(bytes32 => AddressElement) map;
    // separate list of known keys
    bytes32[] keys;
    uint mapSize;

    struct AddressElement {
        uint keyIdx;
        address value;
    }

    /**
     * @notice Inserts the given address value at the specified key.
     *
     * @param key the key
     * @param value the value
     * @return true, if the entry already existed and was replaced, false if a new entry was created
     */
    function insert(bytes32 key, address value) returns (bool exists)
    {
        exists = map[key].value != 0x0;
        if (!exists) {
            var keyIndex = keys.length++;
            keys[keyIndex] = key;
            map[key] = AddressElement(keyIndex, value);
            mapSize++;
        } else {
            // overwrite previous value
            map[key].value = value;
        }
    }

    /**
     * @return true if the map contains a value at the specified key, false otherwise.
     */
    function exists(bytes32 key) constant returns (bool exists) {
        return map[key].value != 0x0;
    }

    /**
     * @return the key at the given index or 0 if the index is out of bounds
     */
    function keyAtIndex(uint index) constant returns (bytes32 key) {
        if(index >= 0 && index < keys.length) {
            return keys[index];
        }
        return 0;
    }

    /**
      * @notice Returns the key at the given index position and the index of the next
      * artifact, if there is one, or 0 otherwise.
      * This method can be used as an iterator: As long as a nextIndex > 0 is returned, there
      * is another key.
    */
    function keyAtIndexHasNext(uint idx) public constant returns (bytes32 key, uint nextIndex) {
        nextIndex = 0;
        key = 0;
        if (idx >= 0 && idx < keys.length) {
            key = keys[idx];
            if (++idx < keys.length) {
                nextIndex = idx;
            }
        }
        return (key, nextIndex);
    }

    /**
      * @notice Returns the value at the given index position and the index of the next
      * artifact, if there is one, or 0 otherwise.
      * This method can be used as an iterator: As long as a nextIndex > 0 is returned, there
      * is another value.
    */
    function valueAtIndexHasNext(uint idx) public constant returns (address addr, uint nextIndex) {
        nextIndex = 0;
        addr = 0x0;
        if (idx >= 0 && idx < keys.length) {
            addr = value(keys[idx]);
            if (++idx < keys.length) {
                nextIndex = idx;
            }
        }
        return (addr, nextIndex);
    }

    /**
     * @return the index of the given key or -1 if the key does not exist
     */
    function keyIndex(bytes32 key) constant returns (int index) {
        var elem = map[key];
        if(elem.value == 0x0){
            return -1;
        }
        return int(elem.keyIdx);
    }

    /**
     * @return the size of the mapping, i.e. the number of currently stored entries
     */
    function size() constant returns (uint) {
        return mapSize;
    }

     /**
      * @return the address value registered at the specified key
      */
    function value(bytes32 key) constant returns (address addr) {
        if(map[key].value != 0x0) {
            return map[key].value;
        }
        else return 0x0;
    }
}
