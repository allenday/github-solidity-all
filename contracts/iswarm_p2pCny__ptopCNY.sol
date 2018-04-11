pragma solidity ^0.4.15;

import "./BothSigners.sol";

contract Bilateral is BothSigners {

    
    struct PledgeStatus {
        uint256 cashPledge; // 交易双方中数字货币持有方的押金
        bool locked; // 押金是否已经在别的交易中抵押
        
    }

    struct Arbitrator {
        uint256 cash; // 仲裁人的押金
        bool locked; // 是否因正在应仲裁某笔交易仲裁人的押金被锁定
    }

    
    
    mapping(address => PledgeStatus) public cashPledge; // 记录aliceBank的押金
    mapping(address => Arbitrator) public arbitrators; // 记录仲裁人的押金
    
    
    address public owner;
    

    event StartDeposit(address _aliceBank, address _bobCustomer, bytes32 _hash);
    event EndDeposit(address _aliceBank, address _bobCustomer, bytes32 _hash);
    event AskArbitrator(address _arbitrator, bytes32 _hash);
    event UnlockCashpledge(bytes32 _hash);
    event Arbitrate(address _bob, address _alice, bytes32 _hash, bool _bobResult);
    

    function Bilateral() public {
        owner = 0x1eB3162901545cB116b780f3456186b5D1396142;
    }

    

    /* ** Begin deposit
    
    */ 

    // _seller 和 _buyer 同时作为参数才能在双方提交时保持msg.data完全相同

    function startPtopDeposit(address _seller, address _buyer, bytes32 _hash, uint256 _blockNumForTransfer, uint256 _blockNumForAskAbitrator) public returns (bool) {
        require(_seller != _buyer);
        require(msg.sender==_seller || msg.sender == _buyer); // 保证签名的人是_seller 或 _buyer
        require((cashPledge[_seller].cashPledge>10**18 && !cashPledge[_seller].locked) /* || (cashPledge[_buyer].cashPledge>10**18 && !cashPledge[_buyer].locked) */); // 检查数字资产持有方的ETH余额大于零且没有作为押金
        
        // 记录签名: msg.data 完整的calldata，包括msg.sig,即被调用的智能合约的方法编码的前四个字节和调用参数

        if (msg.sender == _seller && !signRecord[keccak256(msg.data)].signedBank) {
            signRecord[keccak256(msg.data)].aliceBank = _seller; // 要求数字货币持有方，即智能合约押金方首先调用这个方法
            signRecord[keccak256(msg.data)].bobCustomer = _buyer;
            signRecord[keccak256(msg.data)].signedBank = true;
            return true;
        } else if ( (msg.sender == signRecord[keccak256(msg.data)].bobCustomer) && (signRecord[keccak256(msg.data)].aliceBank == _seller) && (!signRecord[keccak256(msg.data)].signedCustomer) ) {
            signRecord[keccak256(msg.data)].signedCustomer = true;
        } else {
            return false;
        }     
        cashPledge[signRecord[keccak256(msg.data)].aliceBank].locked = true; // 数字资产持有方的ETH用做押金：只能在一次交易中使用
        pTransactions[_hash].startBlock = block.number;
        pTransactions[_hash].blockNumForTransfer = _blockNumForTransfer; // 转账所需时间（转换为区块数，出一个块的时间平均14s。）
        pTransactions[_hash].blockNumForAskAbitrator = _blockNumForAskAbitrator; // 可以请求仲裁的时间（转换为区块数）
        pTransactions[_hash].aliceBank = signRecord[keccak256(msg.data)].aliceBank;
        pTransactions[_hash].bobCustomer = signRecord[keccak256(msg.data)].bobCustomer;

        StartDeposit(pTransactions[_hash].aliceBank,pTransactions[_hash].bobCustomer,_hash);

        return true;

    }

    /* function twoSigned(byte32 _operation) internal returns (bool) {

    } */

    function endPtopDeposit(address _seller, address _buyer, bytes32 _hash) public  returns (bool) {
        require(_seller != _buyer);
        require(msg.sender==_seller || msg.sender == _buyer); // 保证签名的人是_seller 或 _buyer
        require(pTransactions[_hash].aliceBank == _seller);
        require(pTransactions[_hash].bobCustomer == _buyer);
        require(cashPledge[pTransactions[_hash].aliceBank].locked);
        require(!pTransactions[_hash].bEnd);
        //require(signRecord[keccak256(msg.data)].signedBank[0]);
        //require(signRecord[keccak256(msg.data)].signedCustomer[0]);

        // 记录签名
        
        // 记录签名: msg.data 完整的calldata，包括msg.sig,即被调用的智能合约的方法编码的前四个字节和调用参数

        if (msg.sender == _seller && !signRecord[keccak256(msg.data)].signedBank) {
            signRecord[keccak256(msg.data)].aliceBank = _seller; // 要求数字货币持有方，即智能合约押金方首先调用这个方法
            signRecord[keccak256(msg.data)].bobCustomer = _buyer;
            signRecord[keccak256(msg.data)].signedBank = true;
            return true;
        } else if ( (msg.sender == signRecord[keccak256(msg.data)].bobCustomer) && (signRecord[keccak256(msg.data)].aliceBank == _seller) && (!signRecord[keccak256(msg.data)].signedCustomer) ) {
            signRecord[keccak256(msg.data)].signedCustomer = true;
        } else {
            return false;
        }     
         

        cashPledge[pTransactions[_hash].aliceBank].locked = false; // 释放押金
        uint256 reducePledge = cashPledge[pTransactions[_hash].aliceBank].cashPledge;
        owner.transfer(reducePledge/1000); // 收取充值押金的千分之一
        cashPledge[pTransactions[_hash].aliceBank].cashPledge =  reducePledge - reducePledge/1000;
        EndDeposit(pTransactions[_hash].aliceBank,pTransactions[_hash].bobCustomer,_hash);

        return true;
    }

    function withdrawPledge() public returns (bool) {
        require(cashPledge[msg.sender].cashPledge>0);
        require(!cashPledge[msg.sender].locked);
        // require(block.number>)
        msg.sender.transfer(cashPledge[msg.sender].cashPledge);
        cashPledge[msg.sender].cashPledge = 0;
        return true;
    }

    function beArbitrator() payable public returns(bool) {
        require(msg.value >= 5 ether);               // 至少存5个ETH到智能合约
        arbitrators[msg.sender].cash = msg.value;
    }

    function quitArbitrator() public returns (bool) {
        require(arbitrators[msg.sender].cash > 0);
        require(!arbitrators[msg.sender].locked);
        msg.sender.transfer(arbitrators[msg.sender].cash);
        delete arbitrators[msg.sender];

    }
    
    function askArbitrator(address _arbitrator, bytes32 _hash) public returns (bool) {
        require(block.number >= pTransactions[_hash].startBlock + pTransactions[_hash].blockNumForTransfer); // 检查进入仲裁请求时间段，但还没结束
        require(block.number <= pTransactions[_hash].blockNumForAskAbitrator + pTransactions[_hash].startBlock + pTransactions[_hash].blockNumForTransfer);
        require(arbitrators[_arbitrator].cash>0);
        require(!cashPledge[_arbitrator].locked);
        pTransactions[_hash].arbitrator = _arbitrator;
        AskArbitrator(_arbitrator,_hash);
        return true;
    }

    function arbitrate(address _seller, address _buyer, bytes32 _hash, bool _bobResult) public returns (bool) {
        require(msg.sender == pTransactions[_hash].arbitrator);
        arbitrators[msg.sender].locked = true;
        if (pTransactions[_hash].aliceBank == _seller && pTransactions[_hash].bobCustomer == _buyer ) {
            pTransactions[_hash].arbitrateResult = _bobResult;
        } /* else if (signRecord[_hash].aliceBank == _bob && signRecord[_hash].bobCustomer == _alice) {
            if (true == _bobResult) {
                 signRecord[_hash].arbitrateResult = false;
            } else {
                signRecord[_hash].arbitrateResult = true;
            }
        } */

        if (true == pTransactions[_hash].arbitrateResult) {
            // 说明Alice并没有转等值的加密数字货币给Bob
            uint256 alicePledge = cashPledge[pTransactions[_hash].aliceBank].cashPledge;
            owner.transfer(alicePledge/1000); // 收取充值押金的千分之一
            alicePledge = alicePledge - alicePledge/1000;
            msg.sender.transfer(alicePledge / 10);
            address bobCustomer = pTransactions[_hash].bobCustomer;
            bobCustomer.transfer(alicePledge - alicePledge / 10);
            cashPledge[pTransactions[_hash].aliceBank].cashPledge = 0;
            cashPledge[pTransactions[_hash].aliceBank].locked = false;
            Arbitrate(_buyer,  _seller,  _hash,  _bobResult);
        } else {
            // 哦，系统出错：Alice按约定转出了，但Bob没在约定时间内收到。我也不知道怎么办。
            Arbitrate(_buyer,  _seller,  _hash,  _bobResult); 
        }

        return true;
        
    }

    function unlockCashpledge(bytes32 _hash) public returns (bool) {
        require(cashPledge[msg.sender].locked);        
        require(block.number > pTransactions[_hash].blockNumForAskAbitrator + pTransactions[_hash].startBlock + pTransactions[_hash].blockNumForTransfer);
        require(msg.sender == pTransactions[_hash].aliceBank || msg.sender == pTransactions[_hash].bobCustomer);
        cashPledge[msg.sender].locked = false;
        UnlockCashpledge(_hash);
        return true;
    }

    function () payable {
        cashPledge[msg.sender].cashPledge += msg.value;
    }

    /* ** End deposit
    
    */ 
}