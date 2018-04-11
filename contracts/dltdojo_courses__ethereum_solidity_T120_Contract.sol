pragma solidity ^0.4.14;

// There are two types of accounts in Ethereum state:
// 1. Normal or externally controlled accounts
// 2. contracts

contract Foo {

    uint public bar;
    
    function add() payable {
        bar += 1;
    }
    
    function () payable {
        add();
    }

    // fee = Gas * Gas Price
    // https://rinkeby.etherscan.io/tx/0xc73f5aa1c7e8daa519180cb78c19f60c1169390c0f66cc9754605a2e470f9860
    // https://rinkeby.etherscan.io/tx/0x0504f42eb631eb242a6936298db17793db9a60b76ba8aa7b20b54f9c1de43b08
    // Actual Tx Cost/Fee: 0.02586964 Ether = (Gas Used By Txn) * (Gas Price)
    // Gas Used By Txn: 1293482
    // Gas Price: 0.00000002 Ether (20 Gwei) 

    // 需要支付交易費情形
    // 1. Writing to storage
    // 2. Creating a contract
    // 3. Calling an external function which consumes a large amount of gas
    // 4. Sending Ether
}

contract FooTester {

    // fallback 100 ether
    function () payable {}
    
    Foo public foo = new Foo();
    
    function testAdd(){
        // add functioin
        foo.add.value(1 ether)();
    }
    
    function testFallbackThenAdd(){
        // fallback function
        foo.call.value(1 ether)();
    }
    
    function testTransferGasIssue(){
        foo.transfer(1 ether);
        
        // foo.call.gas(0).value(1 ether)();
        //
        // x.transfer(amount) = x.call.gas(0).value(amount)();
        // solidity - send VS call - differences and when to use and when not to use - Ethereum Stack Exchange 
        // https://ethereum.stackexchange.com/questions/6470/send-vs-call-differences-and-when-to-use-and-when-not-to-use
        //
    }
    
    function testTransferGas(){
        foo.call.gas(21000).value(1 ether)();
    }
}


// TODO 
// FooTester - Create - 10 ether
// testAdd()
// testTransferGasIssue