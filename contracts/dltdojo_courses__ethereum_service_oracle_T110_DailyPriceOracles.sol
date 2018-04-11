pragma solidity ^0.4.14;

// Daily Price Oracles » Brave New Coin https://bravenewcoin.com/services/oracles/daily-price-oracles
// The BNC Bitcoin Liquid Index (BNC-BLX)
// https://create.smartcontract.com/#/contracts/35495df8a3031f4cd342e0a476e64e5d
// Ethereum Address: 0x182f88d457b26196a263a8af45caa1f0b6b3b1c3 
// Read Function Address: 9fa6a6e3
// https://api.bravenewcoin.com/ep_pub/v2/gwa-eod-latest-twap?&coin=BTC
/*
{ "success": true, "source": "BraveNewCoin", "time_stamp": 1503792000, "utc_date": "2017-08-27 00:00:00", 
"coin_symbol": "BTC", "coin_name": "Bitcoin", "eod_twap": "4345.19575258", "price_currency": "USD", 
"price_currency_name": "United States Dollar" }
*/

contract Oracle{
	function update(bytes32 _newCurrent);
	function current()constant returns(bytes32 _current);
}

contract MyOracle is Oracle {
    
    bytes32 x;
    // 4345.19575258
    // 434519575258
    // 0x652B628ADA
    // "0x00000000000000000000000000000000000000000000000000000652B628ADA"
    function update(bytes32 _newCurrent) {
        x = _newCurrent;
    }
	
	function current() constant returns(bytes32 _current){
	    return x;
	}
	
	function oracleCurrentInt() returns (uint){
        return uint(x);
    }
}

contract MyOracle2{
    
    uint x;
    function update(uint _newCurrent) {
        x = _newCurrent;
    }
	
	function current() constant returns(uint _current){
	    return x;
	}
}

contract Foo {
    
    MyOracle2 oracle;
    
    function setMyOracle2(address _addrMyOracle){
        oracle = MyOracle2(_addrMyOracle);
    }
    
    function mbtcToUsd(uint _value) returns (uint){
        return oracle.current() * _value / 1000;
    }
}

// TODO
// ETHEREUM PRICE ORACLE
// SmartContract https://create.smartcontract.com/#/contracts/0ccd9464f479480e6a25d4b21e54d023