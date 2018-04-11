pragma solidity ^0.4.14;
// 
// event http://solidity.readthedocs.io/en/develop/contracts.html#events
// 
// the arguments to be stored in the transaction’s log
// a special data structure in the blockchain. 
// These logs are associated with the address of the contract and will be incorporated into the blockchain 
// and stay there as long as a block is accessible (forever as of Frontier and Homestead, but this might change with Serenity). 
// Log and event data is not accessible from within contracts (not even from the contract that created them).
//
// All non-indexed arguments will be stored in the data part of the log.
// 
// ANT ERC 20 token 
// https://etherscan.io/address/0x960b236A07cf122663c4303350609A66A7B288C0#code
// event Transfer(address indexed from, address indexed to, uint value);
// Event logs
// https://etherscan.io/tx/0x4c7a1d3e6172cd15de1932704f036d100ee4c0a1c519ade85af3126ebf39bdd2#eventlog
// Topics = indexed
// Data = non-indexed
// Topics[0] = keccak256("Transfer(address,address,uint256)"), the signature of the event.

contract FooEvent {
    
    event Event1( uint _value );
    event Event2( address _address, uint _value );
    event Event3( address indexed _address, uint _value );
    
    function testEvent() payable {
        Event1(msg.value);
        Event2(this, msg.value);
        Event3(this, msg.value);
    }

    // Etherscan EventLogs[2] - Matches Topics[1] - search address

}