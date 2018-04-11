pragma solidity ^0.4.15;

contract BothSigners {

    struct Signers {
        address aliceBank;
        address bobCustomer;
        bool signedBank;
        bool signedCustomer;        
    }

    struct PtopTransaction {
        address aliceBank;
        address bobCustomer;
        uint256 blockNumForTransfer;
        uint256 blockNumForAskAbitrator;
        uint256 startBlock;
        address arbitrator;
        
        bool bEnd; // 记录是否结束
        bool arbitrateResult; // true: bobCustomer win; false 
    }



    mapping(bytes32 => Signers) public signRecord; // 记录一个函数调用的签名双方及签名情况 bytes32 指 sha3(msg.data)
    mapping(bytes32 => PtopTransaction ) pTransactions; // 记录一个P2P 交易状态，bytes32 指被调用函数的输入参数中的_hash
}