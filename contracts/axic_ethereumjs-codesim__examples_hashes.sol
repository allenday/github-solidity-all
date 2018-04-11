contract HashTest {
  function testSHA3() returns (uint256) {
    address addr1 = 0x43989fb883ba8111221e89123897538475893837;
    address addr2 = 0;
    uint val = 10000;
    uint timestamp = 1448075779;

    return uint256(sha3(addr1, addr2, val, timestamp)); // will return c3ab5ca31a013757f26a88561f0ff5057a97dfcc33f43d6b479abc3ac2d1d595
  }

  function testSHA256() returns (uint256) {
    address addr1 = 0x43989fb883ba8111221e89123897538475893837;
    address addr2 = 0;
    uint val = 10000;
    uint timestamp = 1448075779;

    return uint256(sha256(addr1, addr2, val, timestamp)); // will return 344d8cb0711672efbdfe991f35943847c1058e1ecf515ff63ad936b91fd16231
  }
 
  function testRIPEMD160() returns (uint160) {
    address addr1 = 0x43989fb883ba8111221e89123897538475893837;
    address addr2 = 0;
    uint val = 10000;
    uint timestamp = 1448075779;

    return uint160(ripemd160(addr1, addr2, val, timestamp)); // will return a398cc72490f72048efa52c4e92067e8499672e7
  }
}
