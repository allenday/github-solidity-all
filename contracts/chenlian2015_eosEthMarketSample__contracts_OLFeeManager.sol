pragma solidity ^0.4.15;


import "./OLFeeManagerInterface.sol";
import "./OLSuperManager.sol";
import "./OLCommonCall.sol";
import "./OLAddressSuperManager.sol";

contract OLFeeManager is OLFeeManagerInterface,OLAddressSuperManager,OLCommonCall, OLCommonConfigure {
    string private constant TAG = "OLFeeManager";
    mapping (string => uint)  private feeSetting;

    mapping (string => uint)  private feeFeedBackSetting;

    mapping (address => uint)  private feeFeedBackAwardBalance;

    function setFee(string serverName, uint fee) public returns (uint){
        addLog(TAG, "1");

        if(getSuperManagerContractAddress() == address(0x0)){
            return errorCode_addressIsEmpty;
        }

        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());
        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLFeeManager")) {
            return errorCode_noPermitAccess;
        }

        addLog(TAG, "2");
        feeSetting[serverName] = fee;
        return errorCode_success;
    }

    function setFeedBackFee(string serverName, uint fee) public returns (uint){
        addLog(TAG, "3");
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());
        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLFeeManager")) {
            return errorCode_noPermitAccess;
        }
        addLog(TAG, "4");
        feeFeedBackSetting[serverName] = fee;
        return errorCode_success;
    }

    function getFee(string serverName) public returns (uint){
        return feeSetting[serverName];
    }

    function getFeedBackFeeAward(string serverName) public returns (uint){
        return feeFeedBackSetting[serverName];
    }

    function addFeeFeedBack(address serverPorvider, string contractName) public returns (uint){
        addLog(TAG, "7");
        OLSuperManager olSuperManager = OLSuperManager(getSuperManagerContractAddress());
        if (!olSuperManager.isUserHasPermissonToModify(msg.sender, "OLFeeManagerAddFeeFeedBack")) {
            return errorCode_noPermitAccess;
        }
        addLog(TAG, "8");
        feeFeedBackAwardBalance[serverPorvider] += getFeedBackFeeAward(contractName);
        return errorCode_success;
    }
}