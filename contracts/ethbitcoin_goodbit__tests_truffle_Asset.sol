pragma solidity ^0.4.11;


contract Assert {

    function transferFrom(uint256 _real,uint256 _expected) returns (bool areEqualed){
        return _real == _expected;
    }

}
