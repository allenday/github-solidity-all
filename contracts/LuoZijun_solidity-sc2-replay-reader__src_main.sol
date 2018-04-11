pragma solidity ^0.4.8;

import {Math} from './math.sol';
import {Mpq} from './mpq.sol';
import {SC2Replay, SC2Protocol} from './sc2/replay.sol';



library HelloWorld {
    function add(uint a, uint b) returns (uint c){
        c = a + b;
    }
    function hi() returns(string) {
        return "Hello, 世界！";
    }
    function test_bytes(bytes a) returns (string) {
        return string(a);
    }
}


