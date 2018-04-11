pragma solidity ^0.4.15;


import "./OLRandomContract.sol";
import "./OLPublicAddress.sol";
import "./OLMarketServerInterface.sol";
import "./OLServerInterface.sol";
import "./OLBlackWhiteListInterface.sol";
import "./StantardTokenInterface.sol";
import "./OLFeeManagerInterface.sol";
import "./OLCommonConfigure.sol";
import "./OLLogToolInterface.sol";


contract OLLogTool is OLLogToolInterface {

    string [] private logTAG;

    string [] private logsContent;

    function addLog(string log, string logContent) public {
        logTAG.push(log);
        logsContent.push(logContent);
    }

    function length() public returns (uint){
        return logTAG.length;
    }

    function getTagAt(uint nIndex) public returns (string){
        return logTAG[nIndex];
    }

    function getContentAt(uint nIndex) public returns (string){
        return logsContent[nIndex];
    }

    function clear() public {
        delete logTAG;
        delete logsContent;
    }
}