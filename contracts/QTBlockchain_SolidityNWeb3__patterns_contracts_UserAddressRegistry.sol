pragma solidity ^0.4.4;

/**
 * Implements the registry for address => name mapping
 *  * 
 * Pattern: Mapping Iteration
 **/

contract UserAddressRegistry {

  address   owner;


  
// =======
  struct User {
    bytes32   name;
    uint      lastUpdated;
  }

  // Manages the mapping between address & name
  mapping(address => User)  addressMap;

  // Manages the list of addresses
  address[]   addresses;

  modifier OwnerOnly() {
    if(msg.sender == owner) _;
    else revert();
  }

  function UserAddressRegistry(){
    owner = msg.sender;
  }

  // Registers the name
  function registerName(bytes32 name) returns (bool){
    // if(name == 0x0) return false;
    if(name == bytes32(0x0)){
      // owner wants to delete the registration
      if(addressMap[msg.sender].name != bytes32(0x0)){
        delete(addressMap[msg.sender]);
      }
      removeFromAddresses(msg.sender);
      return false;
    }

    if(addressMap[msg.sender].name == bytes32(0x0)){
      addresses.push(msg.sender);
    }
    addressMap[msg.sender].name = name;
    addressMap[msg.sender].lastUpdated = now;
    return true;
  }

  // Only Owner can update the name 
  function updateName(address given, bytes32 name) OwnerOnly returns (bool){
    if(addressMap[given].name == bytes32(0x0)) return false;
    addressMap[given].name = name;
    addressMap[msg.sender].lastUpdated = now;
    return true;
  }

  // Owner can force delete
  function deleteName(address given) OwnerOnly returns (bool){
    delete(addressMap[given]);
    removeFromAddresses(given);
    return true;
  }


  // Returns the count of registered names
  function  count() constant returns (uint){

    return addresses.length;

  }

  
  // Returns the address-name at the specified index
  function  getByIndex(uint index) constant returns (address, bytes32,uint){
    if(index >= addresses.length) return;
    address addr = addresses[index];
    return (addr, addressMap[addr].name, addressMap[addr].lastUpdated);
  }

  // Returns the address-name by way of the address
  function  getByAddress(address addr) constant returns (address,bytes32,uint){
    return (addr, addressMap[addr].name, addressMap[addr].lastUpdated);
  }

  /**
   * Solidity does not provide an out of the box function to remove the 
   * element of an array and shrink it.
   **/
  function removeFromAddresses(address addr) private {
    for(uint i=0; i < addresses.length; i++){
      if(addr == addresses[i]){
        // This simply zeroes out the element - length stays the same
        //delete(addresses[i]);

        // This while loop will shrink size of the array
        while (i<addresses.length-1) {
          addresses[i] = addresses[i+1];
          i++;
        }
        addresses.length--;
        return;
      }
    }
  }
}
