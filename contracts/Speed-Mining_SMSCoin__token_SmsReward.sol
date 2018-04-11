pragma solidity ^0.4.8;

import "./SmsCoin.sol";

contract SMSReward {
    SMSCoin smscoin; //  SMS contract instance

    address[] whiteListAddress;
    event Log(string, uint);
    address owner;

    uint public totalSupply;

    uint256 public constant decimals = 3;

    uint256 public constant UNIT = 10 ** decimals;

    mapping(address => address) public userStructs;

    event Exists(string exists);

    event Message(uint256 holderProfit);
    event Transfer(address indexedFrom, address indexedTo, uint value);

    mapping(address => bool) reward; // mapping to store user reward status

    mapping(address => bool) profitAllowances;

    mapping(address => uint) profitOnAddress;

    uint bronzeRatio = 24;
    uint goldRatio = 32;
    uint platinumRatio = 44;

    uint public totalClassRatio = 0;
    uint public etherBalance = 0;
    uint public lastProfitInETH;

    mapping(address => uint) public classRatios;

    // Modifier for owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    // Constructor which takes address of smart contract
    function SMSReward(address smsCoinAddress) public {
        owner = msg.sender;
        smscoin = SMSCoin(smsCoinAddress);
    }

    // Whitelist address to be allowed in Profit distribution list
    function addWhiteListAddress(address[] addresses) external onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            profitAllowances[addresses[i]] = true;
            if (whiteListAddress.length > 0) {
                if (userStructs[addresses[i]] != addresses[i]) {
                    userStructs[addresses[i]] = addresses[i];
                    whiteListAddress.push(addresses[i]);
                }
            } else {
                userStructs[addresses[i]] = addresses[i];
                whiteListAddress.push(addresses[i]);

            }
        }
    }

    // Whitelist address to remove from Profit distribution list
    function removeWhiteListAddress(address[] addresses) external onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            profitAllowances[addresses[i]] = false;

            for (uint j = 0; j < whiteListAddress.length; j++) {
                if (whiteListAddress[j] == addresses[i]) {
                    delete whiteListAddress[j];
                }
            }
        }
    }

    // Checking if the address is in the whitelist
    function checkWhitelistExist(address addr) external returns(bool success) {
        if (profitAllowances[addr]) {
            Exists("Exist");
            return true;
        } else {
            Exists("Not Exist");
            return false;
        }
    }

    // Should be called after adding all the whitelist addresses
    function sendEthToContract() external payable onlyOwner {
        // ------------ Get ETH into contract ------------
        lastProfitInETH = msg.value;
        etherBalance += msg.value;

        // ------------ Calculating Class ratio ------------
        totalClassRatio = 0;
        for (uint i = 0; i < whiteListAddress.length; i++) {

            // Calculating class ratio
            if (smscoin.balanceOf(whiteListAddress[i]) < 10 * UNIT)         // Less than 10 tokens
                classRatios[whiteListAddress[i]] = (smscoin.balanceOf(whiteListAddress[i]) * bronzeRatio) / 100;
            else if (smscoin.balanceOf(whiteListAddress[i]) < 20 * UNIT)    // Less than 20 tokens
                classRatios[whiteListAddress[i]] = (smscoin.balanceOf(whiteListAddress[i]) * goldRatio) / 100;
            else                                                            // From 20 tokens
                classRatios[whiteListAddress[i]] = (smscoin.balanceOf(whiteListAddress[i]) * platinumRatio) / 100;
            
            // Accumulating class ratio
            totalClassRatio += classRatios[whiteListAddress[i]];            
        }

        // ------------ Calculating Profit ------------
        for (i = 0; i < whiteListAddress.length; i++) {
            profitOnAddress[whiteListAddress[i]] += (classRatios[whiteListAddress[i]] * lastProfitInETH) / totalClassRatio;

            // Set reward availability
            setRewardStatus(whiteListAddress[i], true);
        }
    }

    function checkProfit(address addr) public constant returns(uint) {
        return profitOnAddress[addr];
    }

    // Function to get dividendend on requesting
    function requestDividends() external {
        if (!getRewardStatus(msg.sender))
            revert();
        if (!profitAllowances[msg.sender] && profitOnAddress[msg.sender] > 0)
            revert();

        // Checking enough ETH on balance to be transferred
        if (etherBalance - profitOnAddress[msg.sender] >= 0) {
            etherBalance -= profitOnAddress[msg.sender];
            msg.sender.transfer(profitOnAddress[msg.sender]);
            profitOnAddress[msg.sender] = 0;
        } else
            revert();

        // Reset reward status
        setRewardStatus(msg.sender, false);
    }

    // Transfer available ETH from the contract to owner
    // STRANGE BEHAVIOR, NEED TO BE CHECKED
    function drainETH() external onlyOwner {
        owner.transfer(this.balance);
        etherBalance = 0;
    }

    // Get reward status
    function getRewardStatus(address addr) view private returns(bool isReward) {
        return reward[addr];
    }

    // Set reward status
    function setRewardStatus(address addr, bool status) private {
        reward[addr] = status;
    }

}