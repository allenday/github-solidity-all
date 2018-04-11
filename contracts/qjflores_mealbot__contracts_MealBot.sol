pragma solidity ^0.4.4;

contract MealBot {

  User[] public users;

  struct User {
    bytes32 firstName;
    bytes32 lastName;
    uint balance;
  }

  function addUser(bytes32 _firstName, bytes32 _lastName, uint _balance) returns (bool success) {
    User memory newUser;
    newUser.firstName = _firstName;
    newUser.lastName = _lastName;
    newUser.balance = _balance;

    users.push(newUser);
    return true;
  }

  function getUsers() constant returns (bytes32[], bytes32[], uint[]) {
    uint length = users.length;

    bytes32[] memory firstNames = new bytes32[](length);
    bytes32[] memory lastNames = new bytes32[](length);
    uint[] memory balances = new uint[](length);

    for (uint i = 0; i <users.length; i++) {
      User memory currentUser;
      currentUser = users[i];
      firstNames[i] = currentUser.firstName;
      lastNames[i] = currentUser.lastName;
      balances[i] = currentUser.balance;
    }

    return (firstNames, lastNames, balances);
  }
}