pragma solidity ^0.4.4;


contract AddressRegistry {
    event Registered(address indexed user);

    function register(address _user);
    function deregister(address _user);
    function isRegistered(address _user) constant returns (bool);
}
