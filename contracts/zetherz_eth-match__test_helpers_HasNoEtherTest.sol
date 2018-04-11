pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/ownership/HasNoEther.sol";

contract HasNoEtherTest is HasNoEther {

  // Constructor with explicit payable — should still fail
  function HasNoEtherTest() payable {
  }

}
