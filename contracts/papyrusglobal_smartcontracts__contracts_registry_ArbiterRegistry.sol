pragma solidity ^0.4.18;

import "../common/SafeOwnable.sol";
import "../dispute/Arbiter.sol";


// This is the base contract that your contract ArbiterRegistry extends from.
contract ArbiterRegistry is SafeOwnable {

  // STRUCTURES

  struct ArbiterBean {
    Arbiter arbiter;
    bool exists;
  }

  // PUBLIC FUNCTIONS

  // This is the function that actually insert a record.
  function register(Arbiter arbiter) public onlyOwner {
    address arbiterAddress = address(arbiter);
    require(arbiterAddress != address(0) && !arbiters[arbiterAddress].exists);
    keys.length++;
    keys[keys.length - 1] = arbiterAddress;
    arbiters[arbiterAddress] = ArbiterBean(arbiter, true);
    numArbiters++;
    checkTrusted(arbiter);
  }

  // Tells whether a given key is registered.
  function isRegistered(address key) public view returns (bool) {
    return arbiters[key].exists;
  }

  function getArbiter(address key) public view returns (address arbiterAddress, int256 karma) {
    Arbiter arbiter = arbiters[key].arbiter;
    arbiterAddress = arbiter.arbiterAddress();
    karma = arbiter.karma();
  }

  function getRandomArbiters(uint8 /*number*/) public view onlyOwner returns (Arbiter[] /*arbiterAddresses*/) {
    // TODO
  }

  function getRandomArbiter() public view onlyOwner returns (Arbiter /*arbiter*/) {
    // TODO
  }

  function sortTrusted() public {

    uint256 n = mostTrusted.length;
    Arbiter[] memory arr = new Arbiter[](n);
    uint256 i;

    for (i = 0; i < n; i++) {
        arr[i] = mostTrusted[i];
    }

    Arbiter key;
    uint256 j;

    for (i = 1; i < arr.length; i++) {
        key = arr[i];

        for (j = i; j > 0 && arr[j - 1].karma() < key.karma(); j--) {
            arr[j] = arr[j - 1];
        }

        arr[j] = key;
    }

    for (i = 0; i < n; i++) {
        mostTrusted[i] = arr[i];
    }
  }

  function kill() public onlyOwner {
      selfdestruct(owner);
  }

  // PRIVATE FUNCTIONS

  function checkTrusted(Arbiter arbiter) private {
      if (mostTrusted.length < TRUSTED_ARBITERS_NUBMER || mostTrusted[mostTrusted.length - 1].karma() <= arbiter.karma()) {
          if (!mostTrustedIndex[arbiter.arbiterAddress()].exists) {
              mostTrusted.push(arbiters[address(arbiter)].arbiter);
          }
          sortTrusted();
          if (mostTrusted.length > TRUSTED_ARBITERS_NUBMER) {
              mostTrusted.length--;
          }
      }
  }

  // FIELDS

  // This mapping keeps the arbiters
  mapping(address => ArbiterBean) arbiters;

  // Keeps the total numbers of arbiters in this Registry.
  uint256 public numArbiters;

  // Keeps a list of all keys to interate the arbiters.
  address[] public keys;

  // Those with biggest karma
  Arbiter[] public mostTrusted;

  mapping(address => ArbiterBean) mostTrustedIndex;

  uint8 public constant TRUSTED_ARBITERS_NUBMER = 10;
}
