pragma solidity ^0.4.15;

import "./OLTestSynataxBB.sol";
import "./OLCommonCall.sol";
import "./OLLogToolInterface.sol";

contract OLTestSynatax is OLCommonCall{


    function OLTestSynatax(){

    }

    mapping(string => address) private serverAddress;

    function addLog(string log, string logContent){

        address addrTmp = serverAddress["OLLogTool"];
        if(addrTmp == address(0x0)){
            return;
        }

        OLLogToolInterface olLogToolInterface = OLLogToolInterface(addrTmp);
        olLogToolInterface.addLog(log, logContent);
    }

    function baby()public returns(uint){
        address x;
        if(x == address(0x0)){
        return 3;
        }else{
        return 5;
        }
    }

    function test() public returns(address){
        addLog("hello", "world");
        return address(0);
    }
}