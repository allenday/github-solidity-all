pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CoderForge.sol";
import "../contracts/Forge.sol";

contract TestForge {

  uint public initialBalance = 10000;

  event log(
    Forge forge
  );

  function testSetOrganiserUsingDeployedContract(){

    Forge forge = Forge(DeployedAddresses.Forge());
    address expected = this;

    log(forge);

    forge.setOrganiser(expected);
    // Assert.equal(forge._organiser, expected, "Organiser not set");
  }

  function testInitialBalanceUsingDeployedContract() {
    // address forge_address = 0xfc8ac42c775c36a9083bd57ee0311dfa5fddb86b;
    Forge forge = Forge(DeployedAddresses.Forge());

    log(forge);

    uint expected = 10000;

    // Assert.equal(forge.getBalance(), expected, "Owner should have 10000 MetaCoin initially");
  }

  //function testInitialBalanceWithNewMetaCoin() {
  //MetaCoin meta = new MetaCoin();

  //uint expected = 10000;

  //Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  //}

}
