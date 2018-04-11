pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MySale.sol";


contract TestMySale {
  function bytes32ToString (bytes32 data) returns (string) {
    bytes memory bytesString = new bytes(32);
    for (uint j=0; j<32; j++) {
        byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[j] = char;
        }
    }
    return string(bytesString);
  }

  function contractBaseTests(MySale meta) {
    Assert.equal(meta.hardCapBlock(), 0, "hardCapBlock should be 0");
    Assert.equal(meta.hardCap(), 0, "hardCap should be 0");
    Assert.equal(meta.weiRaised(), 0, "weiRaised should be 0");
  }

  function testInitialBalanceUsingDeployedContract() {
    MySale meta = MySale(DeployedAddresses.MySale());

    contractBaseTests(meta);
  }

  function testInitialBalanceWithNewMySale() {
    uint256 startBlock = block.number + 2;
    uint256 endBlock = block.number + 30000;
    uint256 presaleEndBlock = block.number + 30;
    uint256 rate = 1000;
    uint256 rateDiff = 200;
    address wallet = address(0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDEADBEAA);
    address tokenWallet = address(0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDEADBEEF);
    uint256 softCap = 1000000000000000000;
    // secret hard cap 2.1 ether
    uint256 hardCap = 2100000000000000000;
    bytes32 hardCapHash = sha256(bytes32ToString(bytes32(hardCap)));
    uint256 endBuffer = 70;

    MySale meta = new MySale(startBlock, endBlock, presaleEndBlock, rate, rateDiff, softCap, wallet, hardCapHash, tokenWallet, endBuffer);

    contractBaseTests(meta);
    Assert.equal(meta.rate(), rate, "rate should be 0");
    Assert.equal(meta.presaleEndBlock(), presaleEndBlock, "presale end block should be properly set");
    Assert.equal(meta.postSoftRate(), 800, "finalRate should be properly set");
    Assert.equal(meta.postHardRate(), 600, "finalRate should be properly set");
    Assert.equal(meta.startBlock(), startBlock, "startBlock should be properly set");
    Assert.equal(meta.endBlock(), endBlock, "endBlock should be properly set");
    Assert.equal(meta.wallet(), wallet, "wallet should be properly set");
    Assert.equal(meta.tokenWallet(), tokenWallet, "tokenWallet should be properly set");
  }

}
