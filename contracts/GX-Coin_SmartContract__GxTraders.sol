pragma solidity ^0.4.2;

import './libraries.sol';
import './GxTradersInterface.sol';

import './GxAccountsInterface.sol';


contract GxTradersPrevious {
    function iterateStart() public constant returns (uint);
    function iterateValid(uint keyIndex) public constant returns (bool);
    function iterateGet(uint keyIndex) public constant returns (address);
    function coinBalance(address mappedAddress) public constant returns (uint32);
    function dollarBalance(address mappedAddress) public constant returns (int160);
}

contract GxCoinInterfaceForTraders { 
    GxAccountsInterface public admins;
    GxAccountsInterface public deploymentAdmins;
}

contract GxTraders is GxTradersInterface {
    using IterableAddressBalanceMapping for IterableAddressBalanceMapping.iterableAddressBalanceMap;
    IterableAddressBalanceMapping.iterableAddressBalanceMap traders;

    bool public isEditable = true;

    address public gxOrdersContract;
    GxCoinInterfaceForTraders public greatCoinContract;

    // required for constructor signature
    function GxTraders(address greatCoinAddress) {
        greatCoinContract = GxCoinInterfaceForTraders(greatCoinAddress);
        isEditable = true;
    }

    modifier callableByDeploymentAdmin {
        if (isDeploymentAdmin(tx.origin)) {
            _;
        }
    }

    modifier callableByGreatCoin {
        if (msg.sender == address(greatCoinContract)) {
            _;
        }
    }

    function isDeploymentAdmin(address accountAddress) public constant returns (bool _i) {
        return greatCoinContract.deploymentAdmins().contains(accountAddress);
    }

    function setEditable(bool editable) callableByDeploymentAdmin {
        isEditable = editable;
    }

    // Function to recover the funds on the contract
    function kill() callableByDeploymentAdmin { suicide(tx.origin); }

    function upgrade(GxTradersPrevious gxTradersToUpgrade, uint256 keyIndexStart, uint256 keyIndexEnd) callableByDeploymentAdmin public {
        // Deep upgrade, via copying previous data
        uint iterationNumber = gxTradersToUpgrade.iterateStart();
        if (keyIndexStart > iterationNumber) {
            iterationNumber = keyIndexStart;
        }
        address iterationCurrent;
        while (keyIndexEnd >= iterationNumber && gxTradersToUpgrade.iterateValid(iterationNumber)) {
            iterationCurrent = gxTradersToUpgrade.iterateGet(iterationNumber);
            traders.add(iterationCurrent, gxTradersToUpgrade.coinBalance(iterationCurrent), gxTradersToUpgrade.dollarBalance(iterationCurrent));
            iterationNumber++;
        }
    }

    function addOrderContract(address gxOrdersAddress) public callableByDeploymentAdmin {
        gxOrdersContract = gxOrdersAddress;
    }

    function upgradeGreatCoin(address greatCoinAddress) public callableByDeploymentAdmin {
        greatCoinContract = GxCoinInterfaceForTraders(greatCoinAddress);
    }    


    modifier callableByGreatCoinOrGxOrders {
        if (msg.sender == address(greatCoinContract) || msg.sender == gxOrdersContract) {
            _;
        }
    }

    function add(address newAddress) callableByGreatCoin public {
        traders.add(newAddress, 0, 0);
    }

    function remove(address removedAddress) callableByGreatCoin public {
        traders.remove(removedAddress);
    }

    function contains(address lookupAddress) public constant returns (bool _c){
        return traders.contains(lookupAddress);
    }

    function iterateStart() public constant returns (uint keyIndex) {
        return iterateNext(0);
    }

    function iterateValid(uint keyIndex) public constant returns (bool) {
        return traders.iterateValid(keyIndex);
    }

    function iterateNext(uint keyIndex) public constant returns (uint r_keyIndex) {
        return traders.iterateNext(keyIndex);
    }

    function iterateGet(uint keyIndex) public constant returns (address mappedAddress) {
        return traders.iterateGet(keyIndex);
    }

    function coinBalance(address mappedAddress) public constant returns (uint32 coinBalance) {
        return traders.valueOfCoinBalance(mappedAddress);
    }

    function dollarBalance(address mappedAddress) public constant returns (int160 dollarBalance) {
        return traders.valueOfDollarBalance(mappedAddress);
    }

    function setCoinBalance(address mappedAddress, uint32 coinBalance) public callableByGreatCoinOrGxOrders {
        traders.setCoinBalance(mappedAddress, coinBalance);
    }

    function setDollarBalance(address mappedAddress, int160 dollarBalance) public callableByGreatCoinOrGxOrders {
        traders.setDollarBalance(mappedAddress, dollarBalance);
    }

    function addCoinAmount(address mappedAddress, uint32 coinAmount) public callableByGreatCoinOrGxOrders {
        traders.addCoinAmount(mappedAddress, coinAmount);
    }

    function addDollarAmount(address mappedAddress, int160 dollarAmount) public callableByGreatCoinOrGxOrders {
        traders.addDollarAmount(mappedAddress, dollarAmount);
    }

    function length() public constant returns (uint) {
        // get the length of the trader list to help with next contract upgrade
        return traders.length();
    }
}