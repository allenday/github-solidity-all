pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/PiggyBank.sol";

contract TestPiggyBank {

  function testNewAccountHasZeroBalance() {
    PiggyBank piggyBank = PiggyBank(DeployedAddresses.PiggyBank());

    uint expected = 0;

    Assert.equal(piggyBank.checkBalance(), expected, "A new Piggy account should start with zero balance");
  }

  function testBalanceAfterDeposit() {
    PiggyBank piggyBank = new PiggyBank();

    piggyBank.deposit(123);

    uint expected = 123;

    Assert.equal(piggyBank.checkBalance(), expected, "A Piggy account should show the correct balance");

  }

  function testDepositCanbeWithdrawn() {
    PiggyBank piggyBank = new PiggyBank();

    piggyBank.deposit(123);

    Assert.equal(piggyBank.withdraw(123), true, "Should be able to withdraw the deposit ");

  }

  function testBalanceCanbeWithdrawn() {
    PiggyBank piggyBank = new PiggyBank();
    uint deposit1 = 123;
    uint deposit2 = 456;

    piggyBank.deposit(deposit1);
    piggyBank.deposit(deposit2);

    uint expected = deposit1 + deposit2;

    Assert.equal(piggyBank.checkBalance(), expected, "Piggy balance should reflect the sum of deposits if no withdraws");
    Assert.equal(piggyBank.withdraw(piggyBank.checkBalance()), true, "Should be able to withdraw balance");
    Assert.equal(piggyBank.checkBalance(),0,"Account balance should be zero after balance withdrawn");
  }


}
