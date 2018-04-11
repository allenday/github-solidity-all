pragma solidity ^0.4.15;


contract OLMarketServerInterface {
    /*
    @param servarName means the server name you will call
    @param versionCaller,means the version of the callback you implemented
    */
    function callServer(string servarName, uint versionCaller)returns (uint reason);

    /*
    @return get the fee needed to call this server
    */
    function getFee(string servarName) public returns (uint);

    /*
    precheck call server
    @return reference OLCommonConfigure.sol
    */
    function preCheckAndPay(string servarName, uint versionCaller, address user)public returns(uint errorCode);

    function getCurrentVersion() public returns (uint version){
        return 1;
    }
}
