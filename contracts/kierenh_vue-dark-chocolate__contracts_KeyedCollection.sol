pragma solidity ^0.4.2;

//
// Defines the base class for a collection of items keyed by a bytes32 (fixed-length string) type.
//
// Implementation Notes: If you define methods without a body, they are abstract.
// This class could add those in the future, just be aware that you don't _deploy_ abstract classes.
// If you do, the error message is vague and misleading: https://github.com/trufflesuite/truffle-contract/issues/34
contract KeyedCollection {
    
    // Keys
    bytes32[] internal keys;

    function KeyedCollection() {
    }

    // Add a key to the dictionary
    function addKey(bytes32 key) internal
    returns(uint length)
    {
        keys.push(key);
        return keys.length - 1;
    }

    // potential abstract method - uncomment to see compile error/warning
    // Gets whether the key is present in the collection
    //function exists(bytes32 key) public constant returns(bool isIndeed);

    // Gets the number of keys
    function getCount() public constant
        returns(uint count)
    {
        return keys.length;
    }
}
