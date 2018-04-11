
import "Identity.sol";
import "Credentials.sol";
import "Saflok.sol";


/**
 * Contract to create and store identity and link to credentials and saflok
 */
contract IdentityManager {

    event NewIdentity(address contractAddress, bytes32 id, bytes32 name);
    event NewCredentials(address contractAddress, bytes32 id, bool hasCredentials);
    event NewSaflok(address contractAddress, bytes32 id, bytes32 expiryDate, bytes32 expiryTime, bytes32 room);

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

    /**
     * Adds a new identity with the specified attributes
     */
    function addIdentity(bytes32 _id, bytes32 _name) returns (bool) {
        Identity identity = new Identity(_id, _name);
        insert(_id, identity);
        NewIdentity(identity, identity.id(), identity.name());
        return true;
    }


/**
     * Adds credentials to an identity
     */
    function addCredentials(bytes32 _id, bool _hasCredentials) returns (bool) {
        Credentials credentials = new Credentials(_id, _hasCredentials);
        insert(_id, credentials);
        NewCredentials(credentials, credentials.id(), credentials.hasCredentials());
        return true;
    }


/**
     * Creates a Saflok key
     */
    function createSaflokKey(bytes32 _id, 
                             bytes32 _expiryDate, 
                             bytes32 _expiryTime, 
                             bytes32 _room) returns (bool) {
        Saflok saflok = new Saflok(_id, _expiryDate, _expiryTime, _room);
        insert(_id, saflok);
        NewSaflok(saflok, saflok.id(), saflok.expiryDate(), saflok.expiryTime(), saflok.room());
        return true;
    }

}