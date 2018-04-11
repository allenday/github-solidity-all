pragma solidity ^0.4.15;

import "./BothSigners.sol";

contract InsurContract is BothSigners {

    struct Insurance {
        uint256 amount; // 保费
        // bytes32 depositHash; // 充值Hash
        uint256 startBlockNum; // 保险有效期开始区块
        //uint256 endBlockNum;
        bool bGetInsurance;
    }

    
    struct InsurFund {
        uint256 amount;
        uint256 numBonus; // 是否参与了第numBonus分红：numBonus<系统分红次数，则没有提取分红；否则已经提取分红。可以一次性提取多次分红。
                          // 每次分红条件：利润==保险储备金。分红办法：每个eth分一个eth. 每个地址的分红: amount*(numBonus-msg.sender.numBonus); msg.sender.numBonus = numBonus;
    }

    mapping(address => mapping(bytes32 => Insurance) ) public insurances; // 保险购买记录

    uint256 public insuranceSaleTotal; 
    uint256 public insuranceClaimTotal;

    uint256 public  validPeriod; // 保险有效期3天
    uint256 public amountInsurance; // 每份保险的保费
    address[] public managerInsurance; // 保险经理人团队
    uint256 numManager;
    mapping(address => uint256 ) public indexManagerInsurance; // 保险经理人团队索引
    mapping(address => InsurFund ) public insuranceFund; // 保险基金：address投入至少5个ether作为保险资金池，投资基金可以做manager
    uint256 public numBonus; // 系统第numBonus次分红
    uint256 public insuranceFundTotal; 
    uint256 public bonusTotal; // 被提取的分红总额
    uint256 public numInsuranceFunder; // 参与保险储备金的人数

    address public owner;

    event ApplyInsurance(address _applyer, bytes32 _hash,  uint256 _amount);
    event ClaimInsurance(address _buyer, uint256 _amountInsurance);
    event FundInsurance(address _funder, uint256 _amountFund);
    event BeManagerInsurance(address _manager);
    event WithdrawFundInsurance(address _sender, uint256 _amount);


    function InsurContract() {
         owner = 0x1eB3162901545cB116b780f3456186b5D1396142;
        amountInsurance = 0.0005 ether;
        managerInsurance.push(owner);
        indexManagerInsurance[owner] = 1; 
        numManager = 1;
    }

    /* ** Begin: Insurance

     */
    function applyInsurance(bytes32 _hash) payable returns(bool) {
        require(msg.value >= amountInsurance);
        insurances[msg.sender][_hash].amount = msg.value;
        //insurances[msg.sender][_hash] = _hash;
        insurances[msg.sender][_hash].startBlockNum = block.number;
        ApplyInsurance(msg.sender, _hash, msg.value);
        return true;
    }

    // 需要申请理赔交易方和保险服务商多签名
    function claimInsurance(bytes32 _hash) returns(bool) {
        require(insurances[pTransactions[_hash].bobCustomer][_hash].amount > 0);
        require(insurances[pTransactions[_hash].bobCustomer][_hash].startBlockNum + validPeriod > block.number);
        
        if ( (msg.sender == pTransactions[_hash].bobCustomer || msg.sender ==pTransactions[_hash].aliceBank) && (!signRecord[sha3(msg.data)].signedCustomer) ) {
            signRecord[sha3(msg.data)].bobCustomer = msg.sender;
            signRecord[sha3(msg.data)].signedCustomer = true;
            return true;
        } else if (msg.sender == managerInsurance[indexManagerInsurance[msg.sender]-1] && (!signRecord[sha3(msg.data)].signedBank) ) {
            signRecord[sha3(msg.data)].aliceBank = msg.sender;
            signRecord[sha3(msg.data)].signedBank = true;
        } else {
            return false;
        }


        if (signRecord[sha3(msg.data)].signedCustomer && signRecord[sha3(msg.data)].signedBank) {
            uint256 getAmount = cashPledge[pTransactions[_hash].aliceBank].cashPledge * 9 / 10;
            signRecord[sha3(msg.data)].bobCustomer.transfer(getAmount);
            ClaimInsurance(pTransactions[_hash].bobCustomer, getAmount);
        }
        return true;
    }

    function fundInsurance() payable returns(bool) {
        require(msg.value > 5 ether);
        require(insuranceFundTotal < 1000*3 ether);
        insuranceFund[msg.sender].amount += msg.value;
        insuranceFundTotal += msg.value;
        FundInsurance(msg.sender,msg.value);
        return true;
    }
    
    // 至少需要投入25 ether
    function beManagerInsurance() returns(bool) {
        require(insuranceFund[msg.sender].amount >= 25 ether);
        managerInsurance.push(msg.sender);

        numManager += 1;
        indexManagerInsurance[msg.sender] = numManager;
        BeManagerInsurance(msg.sender);
        return true;
    }

    function withdrawFundInsurance() returns(bool) {
        require(insuranceFund[msg.sender].amount>0);
        if (indexManagerInsurance[msg.sender]>0) {
            indexManagerInsurance[msg.sender] = 0;
        }

        msg.sender.transfer(insuranceFund[msg.sender].amount);
        insuranceFundTotal -= insuranceFund[msg.sender].amount;
        WithdrawFundInsurance(msg.sender, insuranceFund[msg.sender].amount);
        insuranceFund[msg.sender].amount = 0;
        
        return true;
    }

    // 分红
    function getBonus() returns(bool) {
        // (numBonus%numInsuranceFunder) 分红次数                                                                                                                                                          
        require((numBonus%numInsuranceFunder) > insuranceFund[msg.sender].numBonus);
        require(insuranceSaleTotal - insuranceClaimTotal >= insuranceFundTotal*(numBonus%numInsuranceFunder));
        numBonus += 1;
        msg.sender.transfer(insuranceFund[msg.sender].amount);
        insuranceFund[msg.sender].numBonus += 1;
    }

    /* ** End: Insurance
    
     */


}