pragma solidity ^0.4.14;
//
// web3js - How to get contract internal transactions - Ethereum Stack Exchange 
// https://ethereum.stackexchange.com/questions/3417/how-to-get-contract-internal-transactions
//
// go ethereum - Instrumenting EVM - Ethereum Stack Exchange 
// https://ethereum.stackexchange.com/questions/4446/instrumenting-evm
// 

contract TestFoo {
  
  // https://rinkeby.etherscan.io/address/0x5d3b27cd77d0bbbae4bca97a11b5063885a08ea6
  function TestFoo() payable {
      
  }

  function() payable {}
  
  // https://rinkeby.etherscan.io/tx/0x15c990986dff39fdc148a4419e04e0e6408342bee75fd682a42cad76fcd7dde3
  // http://rinkeby.etherscan.io/remix?txhash=0x15c990986dff39fdc148a4419e04e0e6408342bee75fd682a42cad76fcd7dde3
  // https://rinkeby.etherscan.io/vmtrace?txhash=0x15c990986dff39fdc148a4419e04e0e6408342bee75fd682a42cad76fcd7dde3

  function testInternalCall(){
    address foo1 = 0xF2aDf0e69cC645013585fBBca178de990BE40ED8;
    address foo2 = 0x67cC0309bc079A4524636B7835C70F5b71E24F54;
    
    // Launch debugger 
    // Transferring ether uses a CALL opcode
    // Operand order is: gas, to, value, in offset, in size, out offset, out size.
    
    foo1.transfer(0.099 ether);
    foo2.transfer(0.088 ether);
    
    // ONLY FOR Javascript VM. 
    // require(foo1.balance == 0.099 ether);
    // require(foo2.balance == 0.088 ether);
    // Rinkeby testnet ERROR : callback contain no result Gas required exceeds limit: 3000000
  }
  
   // https://rinkeby.etherscan.io/vmtrace?txhash=0x6d5b7e919681151bfed80c4dfc324d1e29198e0852f196c8d9a142392ba0bb65
   function kill() {
    selfdestruct(msg.sender);
   }
}

// TODO
// 
// Block Height:817831 https://rinkeby.etherscan.io/tx/0x15c990986dff39fdc148a4419e04e0e6408342bee75fd682a42cad76fcd7dde3
// foo1.transfer(0.099 ether) ? https://rinkeby.etherscan.io/address/0xF2aDf0e69cC645013585fBBca178de990BE40ED8
// internal transaction (X) 
// internal call (O)
//

// check balance  
// https://rinkeby.etherscan.io/balancecheck-tool?a=0xF2aDf0e69cC645013585fBBca178de990BE40ED8
// Block Height:817830 result : Balance = 9.100476789 Ether
// Block Height:817832 result : Balance = 9.199476789 Ether
// 

//
// Kovan testnet - Parity Trace 
// https://kovan.etherscan.io/address/0x3e22b564765e7122d1e9ebcacc3871cf77a9556c
// https://kovan.etherscan.io/tx/0xa15db32f36b94ac660dac0517a85c7d810aa28e89584b9a4fcdacb6afed451d0
// https://kovan.etherscan.io/vmtrace?txhash=0xa15db32f36b94ac660dac0517a85c7d810aa28e89584b9a4fcdacb6afed451d0&type=parity
// 

// 
// Example : Ethereum Mainnet internal transaction  https://etherscan.io/tx/0x3e14e817cc5433c755781cd1a390a79a5c3a2f73beb477688f9f6b6658c4f156
// Toos & Utilitits - Parity Trace 
// https://etherscan.io/vmtrace?txhash=0x3e14e817cc5433c755781cd1a390a79a5c3a2f73beb477688f9f6b6658c4f156&type=parity
// Toos & Utilitits - Geth DebugTrace Trace 
// https://etherscan.io/vmtrace?txhash=0x3e14e817cc5433c755781cd1a390a79a5c3a2f73beb477688f9f6b6658c4f156
// 

//
// ERC20 Event Log
// event Transfer(address indexed _from, address indexed _to, uint256 _value);
//