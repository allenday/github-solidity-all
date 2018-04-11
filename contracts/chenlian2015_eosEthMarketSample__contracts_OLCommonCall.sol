pragma solidity ^0.4.15;


import "./OLPublicAddressInterface.sol";
import "./OLLogToolInterface.sol";
import "./OLAddressPublicAddressManager.sol";

contract OLCommonCall is OLAddressPublicAddressManager{

    string public constant marketName = "OLMarket";

    function addLog(string logTag, string logContent) public{
        if(getOuLianPublicAddress() == address(0x0)){
            return;
        }
        OLPublicAddressInterface olPublicAddressInterface = OLPublicAddressInterface(getOuLianPublicAddress());
        address addrTmp = olPublicAddressInterface.getServerAddress("OLLogTool");
        if(addrTmp == address(0x0)){
            return;
        }
        OLLogToolInterface olLogToolInterface = OLLogToolInterface(addrTmp);
        olLogToolInterface.addLog(logTag, logContent);
    }

    function getMyAddress()public returns(address){
        return address(this);
    }
}