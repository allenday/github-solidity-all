pragma solidity ^0.4.18;


contract AuditorRegistry {

  // This is the function that actually insert a record.
  function register(address key, address recordOwner) public;

  function applyKarmaDiff(address key, uint256[2] diff) public;

  // Unregister a given record
  function unregister(address key, address sender) public;

  // Transfer ownership of record
  function transfer(address key, address newOwner, address sender) public;

  function getOwner(address key) public view returns (address);

  // Tells whether a given key is registered.
  function isRegistered(address key) public view returns (bool);

  function getAuditor(address key) public view returns (address auditorAddress, uint256[2] karma, address recordOwner);

  /// @dev Get list of all registered dsp
  /// @return Returns array of addresses registered as DSP with register times
  function getAllAuditors() public view returns (address[] addresses, uint256[2][] karmas, address[] recordOwners);

  function kill() public;
}
