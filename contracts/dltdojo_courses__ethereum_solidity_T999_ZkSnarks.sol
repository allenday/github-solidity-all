pragma solidity ^0.4.14;
// 
// Introduction to zkSNARKs with Examples – ConsenSys Media  https://media.consensys.net/introduction-to-zksnarks-with-examples-3283b554fc3b
// What is zkSNARKs: Spooky Moon Math - Blockgeeks https://blockgeeks.com/guides/what-is-zksnarks/
// 

contract User{}
contract FooContract{

    User anna = new User();
    User carol = new User();

    function escrow () payable {
        require(msg.sender == anna);
    }

    // w = abc
    // x = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
    function C(x, w) returns (bool) {
      return ( sha256(w) == x );
    }
    
    // Anna
    // the generator(G) is run off-chain to produce the proving key(pk) and verification key(vk). 
    // G(C, lambda) = (pk , vk)

    // Carol 
    // prf = P( pk, x, w)
    function claim(bytes32 vk, bytes32 x, bytes32 prf) {
        require(msg.sender == carol);
        // Proof of knowledge C
        // verification algorithm of Zk-Snarks V( vk, x, prf)
        // require(V( vk, x, prf));
        carol.transfer(100 ether);
    }

}