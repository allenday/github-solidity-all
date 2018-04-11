pragma solidity ^0.4.10;


contract UserStore {

  struct UserStruct {
      string userEmail;
      uint userAge;
      uint index;
  }

  mapping(address => UserStruct) private userStructs;
  address[] private userIndex;

  event LogNewUser   (address indexed userAddress, uint index, string userEmail, uint userAge);
  event LogUpdateUser(address indexed userAddress, uint index, string userEmail, uint userAge);

  function isUser(address userAddress) public constant returns(bool isIndeed) {
      if(userIndex.length == 0) return false;
      return (userIndex[userStructs[userAddress].index] == userAddress);
  }

  function insertUser(address userAddress, string userEmail, uint userAge) public returns(uint index) {
      if(isUser(userAddress)) throw;
      userStructs[userAddress].userEmail = userEmail;
      userStructs[userAddress].userAge   = userAge;
      userStructs[userAddress].index     = userIndex.push(userAddress)-1;
      LogNewUser(
          userAddress,
          userStructs[userAddress].index,
          userEmail,
          userAge);
      return userIndex.length-1;
  }

  function getUser(address userAddress) public constant returns(string userEmail, uint userAge, uint index) {
      if(!isUser(userAddress)) throw;
      return(
          userStructs[userAddress].userEmail,
          userStructs[userAddress].userAge,
          userStructs[userAddress].index);
  }

  function updateUserEmail(address userAddress, string userEmail) public returns(bool success) {
      if(!isUser(userAddress)) throw;
      userStructs[userAddress].userEmail = userEmail;
      LogUpdateUser(
          userAddress,
          userStructs[userAddress].index,
          userEmail,
          userStructs[userAddress].userAge);
      return true;
  }

  function updateUserAge(address userAddress, uint userAge) public returns(bool success) {
      if(!isUser(userAddress)) throw;
      userStructs[userAddress].userAge = userAge;
      LogUpdateUser(
          userAddress,
          userStructs[userAddress].index,
          userStructs[userAddress].userEmail,
          userAge);
      return true;
  }

  function getUserCount() public constant returns(uint count) {
      return userIndex.length;
  }

  function getUserAtIndex(uint index) public constant returns(address userAddress) {
      return userIndex[index];
  }

}
