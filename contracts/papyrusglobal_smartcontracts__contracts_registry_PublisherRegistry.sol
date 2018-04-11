pragma solidity ^0.4.18;


contract PublisherRegistry {

    // This is the function that actually insert a record.
    function register(address key, bytes32[5] url, address recordOwner) public;

    // Updates the values of the given record.
    function updateUrl(address key, bytes32[5] url, address sender) public;

    function applyKarmaDiff(address key, uint256[2] diff) public;

    // Unregister a given record
    function unregister(address key, address sender) public;

    //Transfer ownership of record
    function transfer(address key, address newOwner, address sender) public;

    function getOwner(address key) public view returns (address);

    // Tells whether a given key is registered.
    function isRegistered(address key) public view returns (bool);

    function getPublisher(address key) public view returns (address publisherAddress, bytes32[5] url, uint256[2] karma, address recordOwner);

    //@dev Get list of all registered publishers
    //@return Returns array of addresses registered as DSP with register times
    function getAllPublishers() public view returns (address[] addresses, bytes32[5][] urls, uint256[2][] karmas, address[] recordOwners);

    function kill() public;
}
