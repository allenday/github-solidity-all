pragma solidity ^0.4.15;


contract OLBlackWhiteListInterface {

    function setContractServerBlackWhiteListType(string contractName, uint nType)  returns (uint);

    function getContractServerBlackWhiteListType(string contractName)  returns (uint);

    function addToBlackList(string contractName, address addr)  returns (uint);

    function addToWhiteList(string contractName, address addr)  returns (uint);

    function isAddressInBlackList(string contractName, address addr)  returns (bool);

    function isAddressInWhiteList(string contractName, address addr)  returns (bool);

    function isAddrCanCallServer(string contractName, address addr)returns (bool bCanCall);

    function removeFromBlackList(string contractName, address addr)  returns (uint);

    function removeFromWhiteList(string contractName, address addr)  returns (uint);
}