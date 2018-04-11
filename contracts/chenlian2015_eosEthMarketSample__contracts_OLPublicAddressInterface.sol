pragma solidity ^0.4.15;


contract OLPublicAddressInterface {
    function putServerAddress(string contractName, address contractAddress, uint serverStatusPar) public returns (uint);

    function removeServer() public returns (uint);

    function setServerFee(string contractName, uint fee) public returns (uint);

    function serServerStatus(string contractName, uint serverStatusPar) public returns (uint);

    function getServerStatus(string contractName) public returns (uint);

    function getServerAddress(string contractName) public returns (address);

    function getFee(string contractName) public returns (uint);
}