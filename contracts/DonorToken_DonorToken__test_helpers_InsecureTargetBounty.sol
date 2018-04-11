pragma solidity ^0.4.13;


import {Bounty, Target} from "zeppelin-solidity/contracts/Bounty.sol";


contract InsecureTargetMock is Target {
  function checkInvariant() returns(bool){
    return false;
  }
}

contract InsecureTargetBounty is Bounty {
  function deployContract() internal returns (address) {
    return new InsecureTargetMock();
  }
}
