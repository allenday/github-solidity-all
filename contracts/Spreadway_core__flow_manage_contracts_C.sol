pragma solidity ^0.4.16;

contract C {
    event TestEvent(
        uint _value
    );

    event TestEventS(
        uint _value,
        string _svalue
    );
    function() public payable { }


    function ff(string s) public returns (uint) {
        TestEventS(1, s);
        return 1;
    }

    function f(uint a, uint b) public view returns (uint) { // not mutable state
        return a * (b + 42) + now;
    }
    function f2(uint a, uint b) public pure returns (uint) { // not mutable state
        return a * (b + 42);
    }    
}
