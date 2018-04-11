pragma solidity ^0.4.15;

contract OLServerInterface {
    /*
    Called by marke
    @param callFrom ,means who in fact called the server
    @param versionCaller,the version of contact, who in fact called the server
    */
    function callServer(address callFrom, uint versionCaller) public returns (bool);
}