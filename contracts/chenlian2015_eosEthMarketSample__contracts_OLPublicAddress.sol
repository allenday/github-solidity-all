pragma solidity ^0.4.15;

import "./OLSuperManager.sol";
import "./OLCommonConfigure.sol";
import "./OLPublicAddressInterface.sol";
import "./OLAddressSuperManager.sol";
import "./OLCommonCall.sol";

contract OLPublicAddress is OLCommonConfigure,OLAddressSuperManager,OLCommonCall{

    string private constant TAG = "OLPublicAddress";

    mapping(string => address) private serverAddress;

    mapping(string => uint) private serverStatus;//服务状态

    /*
    如果要删除一个服务，则contractAddress设置值为0即可
    if you want to delete one contractName,just set contractAddress=0
    @param fee,means the fee you need to provide to call this server
    */
    function putServerAddress(string contractName, address contractAddress, uint serverStatusPar) public returns (uint) {
        addLog(TAG, "1");
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());
        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLPublicAddress")) {
            return errorCode_noPermitAccess;
        }

        addLog(TAG, "2");
        serverAddress[contractName] = contractAddress;
        serverStatus[contractName] = serverStatusPar;

        return errorCode_success;
    }

    function removeServer(string contractName)public returns(uint){
        addLog(TAG, "3");
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());
        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLPublicAddress")) {
            return errorCode_noPermitAccess;
        }
        addLog(TAG, "4");
        serverAddress[contractName] = address(0x0);
        serverStatus[contractName] = serverStatusRemoved;
    }

    function setServerStatus(string contractName, uint serverStatusPar)public returns(uint){
        addLog(TAG, "5");
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());
        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLPublicAddress")) {
            return errorCode_noPermitAccess;
        }
        addLog(TAG, "6");
        serverStatus[contractName] = serverStatusPar;
        return errorCode_success;
    }

    function getServerStatus(string contractName)public returns(uint){
        return serverStatus[contractName];
    }

    function getServerAddress(string contractName) public returns (address){
        addLog(TAG, "9");
        if(getServerStatus(contractName) != serverStatusNormal){
            return address(0x0);
        }
        addLog(TAG, "10");
        return serverAddress[contractName];
    }

    function addLog(string log, string logContent){

        address addrTmp = serverAddress["OLLogTool"];
        if(addrTmp == address(0x0)){
            return;
        }
        OLLogToolInterface olLogToolInterface = OLLogToolInterface(addrTmp);
        olLogToolInterface.addLog(log, logContent);
    }
}