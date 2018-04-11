pragma solidity ^0.4.14;

// http://remix.ethereum.org/

contract FooHash {
    
    // http://solidity.readthedocs.io/en/develop/units-and-global-variables.html#mathematical-and-cryptographic-functions
    
    // 1. collision-free
    // x!=y and H(x)==H(y)
    bytes32 public free1 = sha256('abc');
    bytes32 public free2 = sha256('abc ');
    bytes32 public free3 = sha256(' abc ');
    
    // Google Online Security Blog: Announcing the first SHA1 collision 
    // https://security.googleblog.com/2017/02/announcing-first-sha1-collision.html
    
    // https://en.bitcoin.it/wiki/Script#Crypto
    // bitcoin OP_RIPEMD160
    bytes20 public ripemdHash160 = ripemd160('abc');
    // bitcoin OP_HASH160
    bytes20 public hash160 = ripemd160(sha256('abc'));
}
