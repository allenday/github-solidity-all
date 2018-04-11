pragma solidity ^0.4.15;


import "./OLRandomContractInterface.sol";
import "./OLMarket.sol";
import "./OLPublicAddress.sol";
import "./OLCommonConfigure.sol";
import "./OLCommonCall.sol";
import "./OLAddressPublicAddressManager.sol";


contract OLLotteryContract is OLRandomContractCallBackInterface,OLCommonCall,OLCommonConfigure {
    string private constant TAG = "OLLotteryContract";
    struct JoinersGroup {
    bytes32 uuid;
    address[] oneGroupLotteryJoiners;
    address prizerOne;
    address[] prizerTwo;
    }

    mapping (address => uint) private balance;

    uint oneTimeJoinFee = 0.000123456 * 1000000000000000000;//10^18次方
    uint currentIndex = 0;

    uint private oneGroupJoiners = 5;

    OLPublicAddress oclpa;

    address[] lotteryJoiners;

    mapping (bytes32 => JoinersGroup) mapJoinersGroup;

    bytes32 [] uuidCacheJoinersGroup;

    OLMarketServerInterface ocMarket;

    event LogJoinOneLottery(address bidder, uint amountto, uint amountfrom); // Event
    event LogFeeNotEnoughForJoinLottery(address bidder, uint sent, uint realNeed); // Event
    event LogError(address bidder, string step); // Event

    function setOneGroupJoinersCount(uint nCount) public {
        addLog(TAG, "1");
        oneGroupJoiners = nCount;
    }

    function OCLotteryContract(){
        oclpa = OLPublicAddress(getOuLianPublicAddress());
    }

    function() payable {
        addLog(TAG, "2");
        balance[msg.sender] += msg.value;
        if (balance[msg.sender] >= oneTimeJoinFee) {
            addLog(TAG, "3");
            joinOneLottery();
            balance[msg.sender] -= oneTimeJoinFee;
        }
        else {
            addLog(TAG, "4");
            LogFeeNotEnoughForJoinLottery(msg.sender, msg.value, oneTimeJoinFee);
        }
    }

    function getCurrentLotteryJoiners() public returns (address[]){
        return lotteryJoiners;
    }

    function getBalance() public returns (uint){
        return balance[msg.sender];
    }


    function joinOneLottery() payable {
        addLog(TAG, "7");
        assert(currentIndex < oneGroupJoiners);
        lotteryJoiners[currentIndex] = msg.sender;

        if (currentIndex >= (oneGroupJoiners - 1)) {
            addLog(TAG, "8");
            bytes32 uuid = keccak256(lotteryJoiners);
            mapJoinersGroup[uuid].uuid = keccak256(lotteryJoiners);

            for (uint i = 0; i < lotteryJoiners.length; i++) {
                mapJoinersGroup[uuid].oneGroupLotteryJoiners.push(lotteryJoiners[i]);
            }
            uuidCacheJoinersGroup.push(uuid);
            ocMarket = OLMarketServerInterface(oclpa.getServerAddress("OCMarket"));
            ocMarket.callServer("OLRandomContract", 1);
            currentIndex = 0;
        }
        else {
            addLog(TAG, "9");
            currentIndex++;
        }
    }


    function callBackForRequestRandom(bytes32 randomValue) public returns (uint){

        addLog(TAG, "10");
        for (uint i = 0; i < uuidCacheJoinersGroup.length; i++) {
            addLog(TAG, "11");
            bytes32 uuidRequest = uuidCacheJoinersGroup[i];
            if (msg.sender != oclpa.getServerAddress("OLRandomContract")) {
                return errorCode_noPermitAccess;
            }

            addLog(TAG, "12");
            uint nIndexFirstPrize = uint(randomValue[0]) % oneGroupJoiners;
            mapJoinersGroup[uuidRequest].prizerOne = mapJoinersGroup[uuidRequest].oneGroupLotteryJoiners[nIndexFirstPrize];


            if (nIndexFirstPrize < (oneGroupJoiners / 2)) {
                addLog(TAG, "13");
                if (mapJoinersGroup[uuidRequest].oneGroupLotteryJoiners.length > nIndexFirstPrize + 2) {
                    addLog(TAG, "14");
                    mapJoinersGroup[uuidRequest].prizerTwo.push(mapJoinersGroup[uuidRequest].oneGroupLotteryJoiners[nIndexFirstPrize + 1]);
                    mapJoinersGroup[uuidRequest].prizerTwo.push(mapJoinersGroup[uuidRequest].oneGroupLotteryJoiners[nIndexFirstPrize + 2]);
                }
                else {
                    addLog(TAG, "15");
                }
            }
            else {
                addLog(TAG, "16");
                if (0 <= nIndexFirstPrize - 2) {
                    addLog(TAG, "17");
                    mapJoinersGroup[uuidRequest].prizerTwo.push(mapJoinersGroup[uuidRequest].oneGroupLotteryJoiners[nIndexFirstPrize - 1]);
                    mapJoinersGroup[uuidRequest].prizerTwo.push(mapJoinersGroup[uuidRequest].oneGroupLotteryJoiners[nIndexFirstPrize - 2]);
                }
                else {
                    addLog(TAG, "18");
                }
            }

            balance[mapJoinersGroup[uuidRequest].prizerOne] += oneTimeJoinFee * 2;
            balance[mapJoinersGroup[uuidRequest].prizerTwo[0]] += oneTimeJoinFee;
            balance[mapJoinersGroup[uuidRequest].prizerTwo[1]] += oneTimeJoinFee;

            delete uuidCacheJoinersGroup;
        }
    }

    function getLotteryResultTotal(address joiner) public returns (uint){
        return balance[joiner];
    }

    function withDrawMyBalance() public {
        addLog(TAG, "19");
        msg.sender.transfer(balance[msg.sender]);
        balance[msg.sender] = 0;
    }
}



