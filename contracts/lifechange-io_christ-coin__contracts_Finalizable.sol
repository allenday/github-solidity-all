pragma solidity ^0.4.11;

import "./Zeppelin/Ownable.sol";

contract Finalizable is Ownable {
  bool public contractFinalized;

  modifier notFinalized() {
    require(!contractFinalized);
    _;
  }

  function finalizeContract() onlyOwner {
    contractFinalized = true;
  }
}