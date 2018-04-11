pragma solidity ^0.4.9;

contract ManyOwnersBaseContract {

    function addOwners(address[] owners) returns (bool isOk);
    function removeOwners(address[] owners) returns (bool isOk);
    function isOwner(address ownerAddress) constant returns (bool isOwner);
}