pragma solidity ^0.4.4;
// 
// https://remix.ethereum.org
// https://github.com/ConsenSys/MultiSigWallet/blob/master/contracts/solidity/MultiSigWallet.sol
//
import "github.com/ConsenSys/MultiSigWallet/contracts/solidity/MultiSigWallet.sol";

// change to 0.4.4 https://remix.ethereum.org/#version=soljson-v0.4.4+commit.4633f3de.js

// 
// 2-of-3
// copy account1,account2
// swich back account0
// new FooWallet() [account0,account1,account2],2
// ["0xca35b7d915458ef540ade6068dfe2f44e8fa733c","0x14723a09acff6d2a60dcdf7aa4aff308fddc160c","0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db"],2
// fallback() 50 ether 
// submitTransaction() "0xdeed",100,"0x00" return transactionId: 0
// confirmTransaction()@account1 0
// transactions() 0
// getBalance()

// submitTransaction() "0xdeed",200,"0x00" return transactionId: 1
// confirmTransaction()@account2 1
// transactions() 1

contract FooWallet is MultiSigWallet{
    function FooWallet(address[] _owners,uint _required) MultiSigWallet(_owners, _required){
        
    }
    
    function getBalance() returns (uint) {
        return this.balance;
    }
}

// Why user ?
contract User {
    function confirmTransaction(MultiSigWallet wallet ,uint txid){
        wallet.confirmTransaction(txid);
    }
}

//
// fallback() 100 
// getBalance()
// initWallet2of3()
// getBalance() and getWalletBalance()
// testSign20f3()
// getBalance() and getWalletBalance()
// 
contract TestWallet{
    
    uint public txid;
    MultiSigWallet w;
    User user1 = new User();
    User user2 = new User();
    
    function initWallet2of3(){
        address[] memory owners = new address[](3);
        owners[0]=this;
        owners[1]=user2;
        owners[2]=user1;
        w = new MultiSigWallet(owners, 2);
        w.send(10 ether);
    }
    
    function testSign2of3() {
        // _initWallet2of3();
        bytes memory data = "foo";
        // 1/3
        txid = w.submitTransaction(0xdeed, 2 ether, data);
        // 2/3
        user1.confirmTransaction(w ,txid);
    }
    
    function getWalletBalance() returns (uint) {
        return w.balance;
    }
    
    function getBalance() returns (uint) {
        return this.balance;
    }
    
    function () payable {}

}