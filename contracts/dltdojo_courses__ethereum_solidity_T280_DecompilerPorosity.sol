pragma solidity 0.4.0;
//
// remix.ethereum.org
// comaeio/porosity: Decompiler for Blockchain-based Ethereum Smart-Contracts  https://github.com/comaeio/porosity

// 1. click Foo-Create
// 2. copy Runtime Bytecode
// 3. run porosity 
/*
CODE=60606040526000357c010000000000000000000000000000000000000000000000000000000090048063a9e966b7146043578063c19d93fb14605d57603f565b6002565b34600257605b60048080359060200190919050506082565b005b34600257606c60048050506090565b6040518082815260200191505060405180910390f35b806000600050819055505b50565b6000600050548156
docker run -it --rm dltdojo/ethtool porosity --code $CODE --decompile

Porosity v0.1 (https://www.comae.io)
Matt Suiche, Comae Technologies <support@comae.io>
The Ethereum bytecode commandline decompiler.
Decompiles the given Ethereum input bytecode and outputs the Solidity code.

Hash: 0xA9E966B7
ERROR: JUMPI destination is null.
function func_a9e966b7 {
      store[var_22Jjz] = arg_4;
}


LOC: 3
Hash: 0xC19D93FB
ERROR: JUMPI destination is null.
function func_c19d93fb {
}


LOC: 2

*/

contract Foo {
    uint public state = 99;
    function setState(uint _value){
        state = _value;
    }
}

// Issue
// 0.4.14 version 
// executeInstruction: NOT_IMPLEMENTED: REVERT

// TODO1 decompile FooTodo
// TODO2 decompile FooTodo - Settings - Enable Optimizatioin
// TODO3 docker run -it --rm dltdojo/ethtool porosity --code $CODE --disasm

contract FooTodo {
    uint public state = 99;
    function setState(uint _value){
        state = _value % 7;
    }
}

// References
// Releases · jpmorganchase/quorum https://github.com/jpmorganchase/quorum/releases/
// https://github.com/dltdojo/container/tree/master/dltdojo/ethtool