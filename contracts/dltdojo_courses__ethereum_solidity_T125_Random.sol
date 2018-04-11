pragma solidity ^0.4.14;

//
// Using random numbers in smart contracts is quite tricky if you do not want miners to be able to cheat.
//
// contract design - When can BLOCKHASH be safely used for a random number? When would it be unsafe? - Ethereum Stack Exchange 
// https://ethereum.stackexchange.com/questions/419/when-can-blockhash-be-safely-used-for-a-random-number-when-would-it-be-unsafe
//

contract FooRandom{
    function random() returns (bytes32) {
        return block.blockhash(block.number-1);
    }
}

// KeyHash
//
// 
// 1  create HostKeyFactory
// 2  _offlineHash 31,32,33
// Result: "0x351ff24e22a5b8f80d9c285574224e37da83e49c7d47b88991231f110b357682"
// Transaction cost: 83292 gas. 
// Execution cost: 61444 gas.
// Decoded: 
// bytes32: 0x351ff24e22a5b8f80d9c285574224e37da83e49c7d47b88991231f110b357682
// 
// 3  setKeyHash "0x351ff24e22a5b8f80d9c285574224e37da83e49c7d47b88991231f110b357682"
// 4 clientVerifyKeyHash 31,32,33,"0x351ff24e22a5b8f80d9c285574224e37da83e49c7d47b88991231f110b357682"
//
contract HostKeyFactory {
    bytes32[3] keys;
    bytes32 public keysHash;
    
    function _offlineHash(bytes32 _key1, bytes32 _key2, bytes32 _key3) constant returns (bytes32){
        keys[0] = _key1;
        keys[1] = _key2;
        keys[2] = _key3;
        return  sha3(keys[0], keys[1], keys[2]);
    }
    
    function setKeyHash(bytes32 _hash){
        keysHash = _hash;
    }
    
    function clientVerifyKeyHash(bytes32 _key1, bytes32 _key2, bytes32 _key3, bytes32 _hash) constant {
        require(_offlineHash(_key1, _key2, _key3) == _hash);
    }
}

//
// HMAC https://en.wikipedia.org/wiki/Hash-based_message_authentication_code
// HMAC_SHA256("key", "The quick brown fox jumps over the lazy dog") = f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8
// 

contract FooProvablyFairGames {
    
    
    function t01_setKey(bytes32 _key){
        key = _key;
    }
    
    // hmac(key, msg)
    function t02_createContractMac(bytes32 _publicSeed, bytes32 hashStorageContractTxid) payable returns (bytes32) {
        return sha3(key, sha3(_publicSeed,);
    }
    
    bytes32 key;
}

// provably fair games
// bitcoin ?
// OP_RETURN - Bitcoin Wiki https://en.bitcoin.it/wiki/OP_RETURN
// nodejs library
// https://www.npmjs.com/package/@provably-fair/core