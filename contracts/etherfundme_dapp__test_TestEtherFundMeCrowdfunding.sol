pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EtherFundMeCrowdfunding.sol";

// TODO add tests
contract TestEtherFundMeCrowdfunding {
  function testEtherFundMeCrowdfunding() {
    EtherFundMeCrowdfunding etherFundMe = EtherFundMeCrowdfunding(DeployedAddresses.EtherFundMeCrowdfunding());
  }
}
