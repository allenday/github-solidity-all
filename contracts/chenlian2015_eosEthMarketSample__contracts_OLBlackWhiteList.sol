pragma solidity ^0.4.15;


import "./OLSuperManager.sol";
import "./OLBlackWhiteListInterface.sol";
import "./OLCommonConfigure.sol";
import "./OLCommonCall.sol";
import "./OLAddressSuperManager.sol";

contract OLBlackWhiteList is OLCommonConfigure,OLAddressSuperManager,OLCommonCall,OLBlackWhiteListInterface{

    mapping  (string => mapping (address => uint))  private whiteList;

    mapping  (string => mapping (address => uint))  private blackList;


    function isAddrCanCallServer(string contractName, address addr)public returns (bool bCanCall){
        uint nType = blackWhiteListType[contractName];
        if (nType == notCheck) {
            return true;
        }
        else if (nType == onlyCheckWhiteList) {
            return isAddressInWhiteList(contractName, addr);
        }
        else if (nType == onlyCheckNotInBlackList) {
            return !isAddressInBlackList(contractName, addr);
        }
        else if (nType == checkWhiteAndBlackList) {
            return isAddressInWhiteList(contractName, addr) && (!isAddressInBlackList(contractName, addr));
        }else {
            return false;
        }
    }

    mapping (string=>uint) private blackWhiteListType;

    function setContractServerBlackWhiteListType(string contractName, uint nType)public returns (uint){
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());

        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLBlackWhiteList")) {
            return errorCode_noPermitAccess;
        }

        blackWhiteListType[contractName] = nType;
    }

    function getContractServerBlackWhiteListType(string contractName)public returns (uint){
        return blackWhiteListType[contractName];
    }

    function addToWhiteList(string contractName, address addr) public returns (uint){
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());

        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLBlackWhiteList")) {
            return errorCode_noPermitAccess;
        }
        whiteList[contractName][addr] = inuse;
    }

    function removeFromWhiteList(string contractName, address addr) public returns (uint){
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());

        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLBlackWhiteList")) {
            return errorCode_noPermitAccess;
        }
        whiteList[contractName][addr] = notinuse;
    }

    function addToBlackList(string contractName, address addr) public returns (uint){
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());

        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLBlackWhiteList")) {
            return errorCode_noPermitAccess;
        }
        blackList[contractName][addr] = inuse;
    }

    function removeFromBlackList(string contractName, address addr) public returns (uint){
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());

        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLBlackWhiteList")) {
            return errorCode_noPermitAccess;
        }
        blackList[contractName][addr] = notinuse;
    }

    function isAddressInWhiteList(string contractName, address addr) public returns (bool){
        return whiteList[contractName][addr] == inuse;
    }

    function isAddressInBlackList(string contractName, address addr) public returns (bool){
        return blackList[contractName][addr] == inuse;
    }
}