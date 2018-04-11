pragma solidity ^0.4.2;

library DMSLibrary {
  struct data {
    address beneficiary;
    bytes32 data;
    bool isValue;
    uint32 expiration_time;
   }
}

contract DMSContract {

  using DMSLibrary for DMSLibrary.data;
  mapping (address => DMSLibrary.data) DMS_data;

  function DMSContract()
  {

  }

  function CreateDMSContract(address beneficiary, bytes32 data, uint32 initial_expiration_time) returns(bool) {
    if( DMS_data[msg.sender].isValue) throw; // already exists

    DMS_data[msg.sender].isValue = true;
    DMS_data[msg.sender].beneficiary = beneficiary;
    DMS_data[msg.sender].data = data;
    DMS_data[msg.sender].expiration_time = initial_expiration_time;
  }

  function kick(uint32 new_expiration_time)
  {
    if( !DMS_data[msg.sender].isValue) throw; // does not exist  

    DMS_data[msg.sender].expiration_time = new_expiration_time;
  }


  function getTimeLeft() returns(uint32 return_time) {
    if( !DMS_data[msg.sender].isValue) throw; // does not exist

    return DMS_data[msg.sender].expiration_time;
  }

  function getExpirationTimeFromAddress(address sender) returns(uint32) {
    if( !DMS_data[sender].isValue) throw; // does not exist

    return DMS_data[sender].expiration_time;
  }

  function getExpirationTime() returns(uint32) {
    if( !DMS_data[msg.sender].isValue) throw; // does not exist

    return DMS_data[msg.sender].expiration_time;
  }

  function isAddressExpired(address sender, uint32 now_time) returns (bool) {
    if( !DMS_data[sender].isValue) throw; // does not exist

    if(now_time > DMS_data[sender].expiration_time)
      return true;
    else
      return false;
  }

  function getDataFromAddress(address sender) returns (bytes32) {
    
    if( !DMS_data[sender].isValue) throw; // does not exist
    if (msg.sender != DMS_data[sender].beneficiary) throw;
    return DMS_data[sender].data;
  }

}
