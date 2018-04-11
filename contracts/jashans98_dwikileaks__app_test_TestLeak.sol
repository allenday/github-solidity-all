pragma solidity ^0.4.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Leak.sol";

contract TestLeak {

  // Load the leak contract here
  Leak leak = Leak(DeployedAddresses.Leak());

  string fake_hash = "12345678910112";
  string hash2 = "QmTTp4WRDWVxEcCM5a3RdmmZfWFi799y146uFjXQobkEgo";

  function testSubmitHash() {
    bool res1 = leak.addSubmittal(fake_hash);
    bool res2 = leak.addSubmittal(hash2);
    Assert.equal(true, res1, "add submittal did not return true");
    Assert.equal(true, res2, "second submittal failed");
  }

  function testReceiveHash() {
    bytes32 received_hash = leak.fetchHash(0);
    Assert.equal(fake_hash, received_hash, "hashes do not match");
  }

  function testReceiveSubmittal() {
    bytes32[20] memory hashes;
    hashes = leak.fetchRecentSubmittals();
    Assert.equal(hashes[0], fake_hash, "first hashes should match");
    Assert.equal(hashes[1], hash2, "second hashes should match");
  }
}