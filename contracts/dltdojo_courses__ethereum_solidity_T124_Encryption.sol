pragma solidity ^0.4.14;
// 
// Everything on the Ethereum blockchain is public.
// 

contract Foo {
    
    uint public a = 10 ;
    
    uint b = 8 ;
    
    function set(uint _b){
        b = _b;
    }
}

// Encrypted.Create
// encrypt 8888,9999,[123,456]
// 
// Value: "0x00000000000000000000000000000000000000000000000000000000000000407cf27a7aa4c6edf4c5b931348e98b152c2d3dfb57a0f447ef99e64f3d78a31a40000000000000000000000000000000000000000000000000000000000000003270f000000000000000000000000000000000000000000000000000000000000a36c0debc015927f9f84aecf80b3ca2f2272dbec388eea998219dde9dd37b1066deb7f96e50b6b01e8fc40cd7f5dd163810e944f5cc16c423ccd724a0ac48e9a"
// Transaction cost: 25853 gas. (caveat)
// Execution cost: 3237 gas.
// Decoded: 
// bytes32[]: 0x270f000000000000000000000000000000000000000000000000000000000000, 0xa36c0debc015927f9f84aecf80b3ca2f2272dbec388eea998219dde9dd37b106, 0x6deb7f96e50b6b01e8fc40cd7f5dd163810e944f5cc16c423ccd724a0ac48e9a
// bytes32: 0x7cf27a7aa4c6edf4c5b931348e98b152c2d3dfb57a0f447ef99e64f3d78a31a4

//
// decrypt 
// 8888,["0x270f000000000000000000000000000000000000000000000000000000000000", "0xa36c0debc015927f9f84aecf80b3ca2f2272dbec388eea998219dde9dd37b106", "0x6deb7f96e50b6b01e8fc40cd7f5dd163810e944f5cc16c423ccd724a0ac48e9a"],"0x7cf27a7aa4c6edf4c5b931348e98b152c2d3dfb57a0f447ef99e64f3d78a31a4"
//
// Value: "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000027b0000000000000000000000000000000000000000000000000000000000000001c8000000000000000000000000000000000000000000000000000000000000"
// Transaction cost: 33554 gas. (caveat)
// Execution cost: 4858 gas.
// Decoded: 
// bytes32[]: 0x7b00000000000000000000000000000000000000000000000000000000000000, 0x01c8000000000000000000000000000000000000000000000000000000000000
//


// 
// Todo
// encrypt and decrypt
// 

//
// 
// encrypted.sol https://gist.github.com/anonymous/dbac90cb1455787a65e92596f7750275
//
//
/*
  Symmetric encryption functions contract.
  
  WARNING: This is not a standardised, reviewed cryptographic algorithm and is
  distributed for test purposes only. The underlying mechanism is a Keccak-256
  based stream cipher, which would be impractically expensive to use on large
  messages, but that the EVM makes significantly cheaper than block ciphers for
  short messages due to the inclusion of a relatively inexpensive SHA3 opcode.
  
  This contract provides three functions to encrypt, decrypt and check the MAC
  on a message. Please note that the only provided way to obtain a MAC is when
  encrypting, and you can only decrypt with a valid MAC using this interface.
  This is quite deliberate, to force the use of authenticated encryption. Stream
  ciphers are highly vulnerable to bit flipping attacks, padding oracle attacks,
  etc without this protection so don't bypass it!
  
  The functions in this library are intended to be used primarily offline by
  Ethereum clients, and invoked within a contract only where a party needs to
  prove that a particular computation took place. They are quite expensive in
  terms of gas!
*/

contract Encrypted {
  // Tags for deriving subkeys
  uint constant TAG_MAC = 1;
  uint constant TAG_CRYPT = 2;
  
  // Encryption box / unbox
  
  event compareMAC(bytes32, bytes32);
  function checkMAC(bytes32 key, bytes32[] cipher, bytes32 expected) constant returns (bool) {
    bytes32 mac = sha3(key, TAG_MAC);
    uint i;
    for (i = 0; i < cipher.length; i++) {
        mac = sha3(mac, cipher[i]);
    }
    mac = sha3(key, TAG_MAC, mac);
    compareMAC(mac, expected);
    return(mac == expected);
  }
  
  function _blockKey(bytes32 key, bytes32 iv, uint idx) constant internal returns (bytes32) {
    return sha3(key, TAG_CRYPT, iv, idx);
  }
  
  function encrypt(bytes32 key, bytes32 iv, bytes32[] memory data) constant returns (bytes32[] memory, bytes32) {
    bytes32[] memory output = new bytes32[](data.length + 1);
    bytes32 mac = sha3(key, TAG_MAC);
    output[0] = iv;
    uint i;
    mac = sha3(mac, iv);
    for (i = 0; i < data.length; i++) {
      output[i+1] = (bytes32) ((uint) (data[i]) ^ (uint) (_blockKey(key, iv, i)));
      mac = sha3(mac, output[i+1]);
    }
    mac = sha3(key, TAG_MAC, mac);
    return (output, mac);
  }
  
  function decrypt(bytes32 key, bytes32[] memory cipher, bytes32 mac) constant returns (bytes32[] memory) {
    if (cipher.length < 2 || !checkMAC(key, cipher, mac)) {
        throw;
    }
    
    bytes32[] memory output = new bytes32[](cipher.length - 1);
    bytes32 iv = cipher[0];
    
    uint i;
    for (i = 1; i < cipher.length; i++) {
      output[i-1] = (bytes32) ((uint) (cipher[i]) ^ (uint) (_blockKey(key, iv, i-1)));
    }
    return output;
  }
}