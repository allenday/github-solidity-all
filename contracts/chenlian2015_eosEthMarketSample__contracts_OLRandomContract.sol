pragma solidity ^0.4.15;


import "./OLRandomContractCallBackInterface.sol";
import "./OLRandomContractInterface.sol";
import "./OLPublicAddressInterface.sol";
import "./OLMarketServerInterface.sol";
import "./OLCommonConfigure.sol";
import "./OLCommonCall.sol";


contract OLRandomContract is OLCommonCall,OLCommonConfigure, OLRandomContractInterface {
    string private constant TAG = "OLRandomContract";

    string currentContractName = "OLRandomContract";

    uint private seedCountNeeded = 3;

    bytes32 constant nNothingProvidedLable = bytes32(0);

    bytes32 constant nHashProvidedLable = bytes32(1);

    bytes32 constant nSeedProvidedLable = bytes32(2);

    struct OneRequest {
    address callBackAddress;

    mapping (bytes32 => bytes32) hashSeed;
    mapping (address => bytes32) senderSeedLable;

    bytes32[] seedIndex;//为了遍历hashSeed
    uint nHashGetedCount;
    uint nSeedGetedCount;
    OLRandomContractInterface callBack;//请求可能来自不同的服务,所以需要一个活的变量
    }

    OneRequest[] private cacheRequests;

    uint private nCurrentIndex = 0;

    function addOneRequest(address addr) private {
        addLog(TAG, "1");
        OneRequest memory oneRequest;
        oneRequest.callBackAddress = addr;
        oneRequest.nHashGetedCount = 0;
        cacheRequests.push(oneRequest);
    }


    function requestOneUUID(address callBackAddress, uint versionCaller) public returns (uint code){
        addLog(TAG, "2");
        OLPublicAddressInterface oclpa = OLPublicAddressInterface(getOuLianPublicAddress());

        OLMarketServerInterface olMarketServerInterface = OLMarketServerInterface(oclpa.getServerAddress(marketName));
        uint nCode = olMarketServerInterface.preCheckAndPay(currentContractName, versionCaller, msg.sender);
        if (nCode != errorCode_success) {
            return nCode;
        }

        addLog(TAG, "3");
        addOneRequest(callBackAddress);
        addLog(TAG, "4");
        return errorCode_success;
    }

    function callServer(address callFrom, uint versionCaller) public returns (bool){
        OLPublicAddressInterface oclpa = OLPublicAddressInterface(getOuLianPublicAddress());
        addLog(TAG, "5");
        if (msg.sender == oclpa.getServerAddress(marketName)) {
            addLog(TAG, "6");
            addOneRequest(callFrom);
        }
    }

    function sendOnlyHash(bytes32 hash) public returns (uint){

        addLog(TAG, "7");
        if (getCurrentNeedsCount() <= 0) {
            addLog(TAG, "8");
            return errorCode_noHashSeedNeeded;
        }

        //一个人，针对一个请求，只能投一次票
        if (cacheRequests[nCurrentIndex].senderSeedLable[msg.sender] == nHashProvidedLable) {
            addLog(TAG, "9");
//            return errorCode_hashSeedProvided;
        }

        cacheRequests[nCurrentIndex].senderSeedLable[msg.sender] = nHashProvidedLable;


        cacheRequests[nCurrentIndex].hashSeed[hash] = nHashProvidedLable;
        cacheRequests[nCurrentIndex].nHashGetedCount++;
        addLog(TAG, "10");
        return errorCode_success;
    }

    function nowCanProvideHash() public returns (bool){
        addLog(TAG, "11");
        if (getCurrentNeedsCount() > 0) {
            addLog(TAG, "12");
            return (cacheRequests[nCurrentIndex].senderSeedLable[msg.sender] != nHashProvidedLable);
        }
        else {
            addLog(TAG, "13");
            return false;
        }
    }

    function sendSeedAndHash(bytes32 seed, bytes32 hash) public returns (uint) {

        addLog(TAG, "14");
        if (getCurrentNeedsCount() <= 0) {
            addLog(TAG, "15");
            return errorCode_noHashSeedNeeded;
        }

        addLog(TAG, "16");
        if (cacheRequests[nCurrentIndex].nHashGetedCount < seedCountNeeded) {
            addLog(TAG, "17");
            return errorCode_hashSeedCountNotEnough;
        }

        addLog(TAG, "18");
        if (hash != keccak256(seed)) {
            addLog(TAG, "19");
            return errorCode_hashSeedNotPair;
        }

        addLog(TAG, "20");
        if (cacheRequests[nCurrentIndex].hashSeed[hash] != nHashProvidedLable) {
            addLog(TAG, "21");
            return errorCode_hashNotProvided;
        }

        addLog(TAG, "22");
        cacheRequests[nCurrentIndex].hashSeed[hash] = seed;
        cacheRequests[nCurrentIndex].seedIndex.push(hash);
        cacheRequests[nCurrentIndex].nSeedGetedCount++;

        if (cacheRequests[nCurrentIndex].nSeedGetedCount == seedCountNeeded) {
            addLog(TAG, "23");
            bytes memory bytesSeed = getBytes(cacheRequests[nCurrentIndex].hashSeed[cacheRequests[nCurrentIndex].seedIndex[0]]);
            for (uint i = 1; i < cacheRequests[nCurrentIndex].seedIndex.length; i++) {
                addLog(TAG, "24");
                bytes32 keytmp = cacheRequests[nCurrentIndex].seedIndex[i];
                bytesSeed = addBytes(cacheRequests[nCurrentIndex].hashSeed[keytmp], bytesSeed);
            }

            while (nCurrentIndex < cacheRequests.length) {
                addLog(TAG, "25");
                OLRandomContractCallBackInterface olRandomContractCallBackInterface = OLRandomContractCallBackInterface(cacheRequests[nCurrentIndex].callBackAddress);
                olRandomContractCallBackInterface.callBackForRequestRandom(keccak256(bytesSeed));
                nCurrentIndex++;
            }
        }

        return errorCode_success;
    }


    function addBytes(bytes32 a, bytes b) private returns (bytes){
        bytes memory c = new bytes(32 + b.length);
        for (uint i = 0; i < c.length; i++) {
            if (i < 32) {
                c[i] = a[i];
            }
            else {
                c[i] = b[i - 32];
            }
        }
        return c;
    }

    function getBytes(bytes32 a) private returns (bytes){
        bytes memory b = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            b[i] = a[i];
        }
        return b;
    }

    function getCurrentNeedsCount() public returns (uint){
        addLog(TAG, "26");
        return cacheRequests.length - nCurrentIndex;
    }
}