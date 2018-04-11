pragma solidity ^0.4.6;

library Lib {
    /* you have to  use 'internal' in library functions */
    function plus(uint _a, uint _b) internal returns (uint r){
        r = _a+_b;
    }
}

contract ContracWithLibrary{

    uint public state;

    function add(uint a, uint b) returns (uint){
        state = Lib.plus(a,b);
        return state;
    }

}
