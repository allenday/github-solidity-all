pragma solidity ^0.4.14;

// 1. OracleFoo - Create
// 2. Foo - Create
// 3. OracleBar - create

contract OracleFoo {
    uint public state = 199;
    function setState(uint _value){
        state = _value;
    }
}


contract Foo {
    
    uint public state = 9;

    function setState(uint _value){
        state = _value;
    }

    function updateStateFromOracleFoo(address _addrOracleFoo){
        OracleFoo oracle = OracleFoo(_addrOracleFoo);
        state = oracle.state();
    }
}


contract OracleBar {
    function setState(address _addrFoo, uint _value){
        Foo foo = Foo(_addrFoo);
        foo.setState(_value);
    }
}

// TODO
// RANDOM.ORG - Integer Generator https://www.random.org/integers/