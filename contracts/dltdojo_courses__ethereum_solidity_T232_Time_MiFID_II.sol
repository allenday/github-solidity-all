pragma solidity ^0.4.14;
//  
// The Markets in Financial Instruments Directive (MiFID II) 
// MiFID II RTS 25: clock synchronization
// Financial services must use more accurate timestamping traceable to UTC.
//
// The ‘Atomic Ledger’ project recorded over 20 million transactions, timestamping each with Co-ordinated Universal Time (UTC), 
// over three hours of trading to the ChainZy distributed ledger system.
// 
// Atomic ledger breakthrough for blockchain | University of Strathclyde  https://www.strath.ac.uk/whystrathclyde/news/atomicledgerbreakthroughforblockchain/
// 
 
contract FooExchange {

   mapping (bytes32 => uint256) public orderExecutionTimeStamp;
   
   function orderExecution(bytes32 orderData, uint utcSync) returns (bytes32) {
       bytes32 id = sha3(orderData, utcSync);
       orderExecutionTimeStamp[id] = utcSync;
       return id;
   }
   
   function orderExecutionBlockTime(bytes32 orderData) returns (bytes32) {
       uint256 nowWhat = now;
       // uint256 nowWhat = nowUtcPrecompiledContract() ?
       bytes32 id = sha3(orderData, nowWhat);
       orderExecutionTimeStamp[id] = nowWhat;
       return id;
   }
}

// 