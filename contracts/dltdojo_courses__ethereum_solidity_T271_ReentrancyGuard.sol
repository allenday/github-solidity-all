pragma solidity ^0.4.4;

// 
// http://solidity.readthedocs.io/en/develop/security-considerations.html#security-considerations
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ReentrancyGuard.sol
// 

import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/ReentrancyGuard.sol';

contract AbstractFund {
    function withdraw() external;
}

contract User {  
    function callWithdraw(AbstractFund fund){
        fund.withdraw();
    }
    function () payable {}
}

contract UserBlack {
    AbstractFund fund;
    function callWithdraw(AbstractFund _fund){
        fund = _fund;
        fund.withdraw();
    }
    function () payable {
        fund.withdraw();
    }
}

contract Fund is AbstractFund{
    /// Mapping of ether shares of the contract.
    mapping(address => uint) shares;
    
    function withdraw() external {
        //
        //if (msg.sender.call.gas(400000).value(shares[msg.sender])())
        //    shares[msg.sender] = 0;
        //
        var share = shares[msg.sender];
        shares[msg.sender] = 0;
        msg.sender.call.gas(400000).value(share)();
    }
    
    function () payable {
        
    }
    
    function testAddUser(address user, uint amount){
        shares[user] = amount ;
    }
}

contract FundGuard is AbstractFund, ReentrancyGuard {
    /// Mapping of ether shares of the contract.
    mapping(address => uint) shares;
    
    function withdraw() external nonReentrant {
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
    
    function testReentracyGuard(){
        FundGuard fund = new FundGuard();
        fund.transfer(100 ether);
        fund.testAddUser(user1, 1 ether);
        fund.testAddUser(userBlack, 1 ether);
        user1.callWithdraw(fund);
        UserCallWithdraw(user1,user1.balance, fund.balance);
        userBlack.callWithdraw(fund);
        UserCallWithdraw(userBlack,userBlack.balance,fund.balance);
    }
    
}
