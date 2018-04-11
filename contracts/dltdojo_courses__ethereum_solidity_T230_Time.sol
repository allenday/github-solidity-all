pragma solidity ^0.4.14;
// 
// Time Units  http://solidity.readthedocs.io/en/develop/units-and-global-variables.html#time-units
// seconds, minutes, hours, days, weeks and years
// 1 == 1 seconds 
// 1 minutes == 60 seconds
// 1 hours == 60 minutes
// 1 days == 24 hours
// 1 weeks == 7 days
// 1 years == 365 days
// Take care if you perform calendar calculations using these units, because not every year equals 365 days and not even every day has 24 hours 
// because of leap seconds. Due to the fact that leap seconds cannot be predicted, an exact calendar library has to be updated by an external oracle.
contract FooTime {
    
    uint public fooInt;
    uint createdTime;
    
    function FooTime(){
        createdTime = now;
    }

    // rinkeby/kovan/GethDevNode test
    function timeInfo() constant returns(uint _blockNumber, uint _blockTimestamp, uint _now) {
        // Block and Transaction Properties
        // now (uint): current block timestamp (alias for block.timestamp)
        _blockNumber = block.number;
        _blockTimestamp = block.timestamp;
        _now = now;
        // The timestamps are saved into the blockheader. 
        // They don't get updated but they are part of the consensus and can't get altered after mined. 
        // https://ethereum.stackexchange.com/questions/9564/how-does-ethereum-avoid-inaccurate-timestamps-in-blocks
    }
    
    function setFooInt(uint x){
        fooInt = x;
    }
    
    function after20Seconds() constant returns(uint){
        require(now > createdTime + 20 seconds);
        return fooInt;
    }

    // constant
    function after10Seconds() returns(uint){
        require(now > createdTime + 10 seconds);
        return fooInt;
    }
    
}

// Ethereum blockchain timestamp
// security - Can a contract safely rely on block.timestamp? - Ethereum Stack Exchange 
// https://ethereum.stackexchange.com/questions/413/can-a-contract-safely-rely-on-block-timestamp/428
// The Yellow Paper does not have any answer to "how much can it be off before it is rejected by other nodes". 
// If block.timestamp is used, the only guarantee (equation 43) is that block.timestamp is greater than that of its parent. 

// 以太坊 - 維基百科 https://zh.wikipedia.org/wiki/%E4%BB%A5%E5%A4%AA%E5%9D%8A

// Ethereum Classic
// July 20th, 2016, at block 1,920,000
// https://etcchain.com/block/number/1920001

// Ethereum 
// Ethereum Block 1920001 Info https://etherscan.io/block/1920001




// Bitcoin blockchain timestamp
// Block timestamp - Bitcoin Wiki https://en.bitcoin.it/wiki/Block_timestamp
// A timestamp is accepted as valid if it is greater than the median timestamp of previous 11 blocks, and less than the network-adjusted time + 2 hours. 
// "Network-adjusted time" is the median of the timestamps returned by all nodes connected to you. 
// As a result, block timestamps are not exactly accurate, and they do not even need to be in order. 
// Block times are accurate only to within an hour or two.

// pizza Bitcoin Transaction https://blockchain.info/tx/cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79
// Pizza for bitcoins?  https://bitcointalk.org/index.php?topic=137.0
// 比特幣歷史 - 維基百科 https://zh.wikipedia.org/wiki/%E6%AF%94%E7%89%B9%E5%B9%A3%E6%AD%B7%E5%8F%B2
// 時間信任來源 ? 論壇/維基百科/權威媒體/區塊鏈