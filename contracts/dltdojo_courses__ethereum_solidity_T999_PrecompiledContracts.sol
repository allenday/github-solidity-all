pragma solidity ^0.4.14;

// 
// http://solidity.readthedocs.io/en/develop/units-and-global-variables.html
// List of pre-compiled contracts - Ethereum Stack Exchange https://ethereum.stackexchange.com/questions/15479/list-of-pre-compiled-contracts
// solidity - How to call the precompiled contracts from my contract? - Ethereum Stack Exchange https://ethereum.stackexchange.com/questions/9773/how-to-call-the-precompiled-contracts-from-my-contract 
//
// Virtual machine optimization and precompiled contracts - Consortium Chain Development · ethereum/wiki Wiki https://github.com/ethereum/wiki/wiki/Consortium-Chain-Development#virtual-machine-optimization-and-precompiled-contracts
// 
// ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)
contract Precompile {
  function foo (bytes32, uint8, bytes32, bytes32) returns (address);
}

contract Testcontract {
  address last = 0x0;

  event Debug(string message, address res);

  Precompile prec = Precompile(0x0000000000000000000000000000000000000001);

  function testMe () {
    last = prec.foo("\x00", uint8(0), "\x00", "\x00");
    Debug("testMe()", last);
  }

}