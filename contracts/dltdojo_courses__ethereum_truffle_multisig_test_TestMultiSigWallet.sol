pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MultiSigWallet.sol";

contract User {
    function confirmTransaction(MultiSigWallet wallet ,uint txid){
        wallet.confirmTransaction(txid);
    }

    function () payable { 
    }
}

contract TestMultiSigWallet {

  // Truffle will send the TestContract one Ether after deploying the contract.
  // testrpc default balance is 50 ether
  uint public initialBalance = 50 ether;

  User user1;
  User user2;
  User user3;

  function beforeAll() {
    // require(this.balance== 50 ether);
  }

  function beforeEach() {
    user1 = new User();
    user2 = new User();
    user3 = new User();
    user1.transfer(1 ether);
    user2.transfer(2 ether);
    user3.transfer(3 ether);
  }

  function testDeployMultiSigWallet(){
    MultiSigWallet wallet = MultiSigWallet(DeployedAddresses.MultiSigWallet());
    // http://solidity.readthedocs.io/en/develop/frequently-asked-questions.html#can-you-return-an-array-or-a-string-from-a-solidity-function-call
    // What is problematic, though, is returning any variably-sized data (e.g. a variably-sized array like uint[]) from a fuction called from within Solidity. 
    // This is a limitation of the EVM and will be solved with the next protocol update.
    // address[] owners = wallet.getOwners();
    Assert.equal(wallet.getOwnersLength(), 3, "Total number of owners should be 3");
  }

  function testInitial1of3() {
    address[] memory owners = new address[](3);
    owners[0]=this;
    owners[1]=user1;
    owners[2]=user2;
    uint required = 1;
    MultiSigWallet wallet = new MultiSigWallet(owners,required);
    wallet.transfer(1.1 ether);
    bytes memory data = "foo";
    // 1/3 (this)
    uint txid = wallet.submitTransaction(user2, 1 ether, data);
    Assert.isTrue(wallet.isConfirmed(txid), "wallet.isConfirmed() should be true after 1/3 confirmations");
    Assert.equal(user2.balance, 3 ether, "User2 should have 3 ether after 1/3 confirmations");
  }

   function testInitial2of2() {
    address[] memory owners = new address[](2);
    owners[0]=this;
    owners[1]=user1;
    uint required = 2;
    MultiSigWallet wallet = new MultiSigWallet(owners,required);
    wallet.transfer(1.1 ether);
    bytes memory data = "foo";
    // 1/2 (this)
    uint txid = wallet.submitTransaction(user2, 1 ether, data);
    Assert.isFalse(wallet.isConfirmed(txid), "wallet.isConfirmed() should be false after 1/2 confirmations");
    // 2/2 (user1)
    user1.confirmTransaction(wallet ,txid);
    Assert.isTrue(wallet.isConfirmed(txid), "wallet.isConfirmed() should be true after 2/2 confirmations");
    // 2+1 = 3 ether
    Assert.equal(user2.balance, 3 ether, "User2 should have 3 ether after 2/2 confirmations");
  }

  function testInitial2of3() {
    address[] memory owners = new address[](3);
    owners[0]=this;
    owners[1]=user1;
    owners[2]=user2;
    uint required = 2;
    MultiSigWallet wallet = new MultiSigWallet(owners,required);
    wallet.transfer(1.1 ether);
    bytes memory data = "foo";
    // 1/3 (this)
    uint txid = wallet.submitTransaction(user3, 1 ether, data);
    Assert.isFalse(wallet.isConfirmed(txid), "wallet.isConfirmed() should be false after 1/3 confirmations");
    // 2/3 (user1)
    user1.confirmTransaction(wallet ,txid);
    Assert.isTrue(wallet.isConfirmed(txid), "wallet.isConfirmed() should be true after 2/3 confirmations");
    // 3+1 = 4 ether
    Assert.equal(user3.balance, 4 ether, "User3 should have 4 ether after 2/3 confirmations");
  }

}
