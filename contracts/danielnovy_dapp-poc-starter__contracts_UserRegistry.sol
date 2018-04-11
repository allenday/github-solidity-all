pragma solidity ^0.4.0;

contract UserRegistry {

  struct User {
    string name;
    uint8 role;
    string photoUrl;
  }

  mapping (address => User) public users;

  function register(address addr, string name, uint8 role, string photoUrl) {
    users[addr].name = name;
    users[addr].role = role;
    users[addr].photoUrl = photoUrl;
  }

}
