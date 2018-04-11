pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "./RokToken.sol";
import "../contracts/SafeMath.sol";


contract TestRokToken {
  using SafeMath for uint256;
  RokToken rok = new RokToken();

  function testInitialBalance() {
    uint expected = 100000000;

    Assert.equal(rok.balanceOf(this), expected, "Owner should have 100000000 ROK initially");
  }

  function testBurn() {
  //  RokToken rok = new RokToken();
    uint value = 10;
    uint expected = rok.totalSupply().sub(value);

    rok.burn(value);

    Assert.equal(rok.totalSupply(), expected, "Error burn");
  }

  function testTransfer() {
  //  RokToken rok = new RokToken();
    uint value = 500;
    address receiver = 0xCE0ff01Bcd7e7758f5c002A07A558BaF706aa565;
    rok.setBalance(receiver,0);
    uint expectedBalanceSender = rok.balanceOf(this).sub(value);
    uint expectedBalanceReceiver = rok.balanceOf(receiver).add(value);

    rok.transfer(receiver, value);

    Assert.equal(rok.balanceOf(receiver), expectedBalanceReceiver, "Error receiver");
    Assert.equal(rok.balanceOf(this), expectedBalanceSender, "Error sender");
  }

  function testTransferFrom(){
  //  RokToken rok = new RokToken();
    uint value = 500;
    address receiver = 0xCE0ff01Bcd7e7758f5c002A07A558BaF706aa565;
    address sender = 0xe241ed8Fe29a6835D4d780f7cC1fb2b3Fb60614C;
    rok.setBalance(receiver,0);
    rok.setBalance(sender,10000);
    rok.setAllowance(sender,this,value);
    uint expectedBalanceReceiver = rok.balanceOf(receiver).add(value);
    uint expectedBalanceSender = rok.balanceOf(sender).sub(value);

    rok.transferFrom(sender,receiver,value);

    Assert.equal(rok.balanceOf(sender), expectedBalanceSender, "Error sender");
    Assert.equal(rok.balanceOf(receiver), expectedBalanceReceiver, "Error receiver");
  }

  function TestApprove(){
  //  RokToken rok = new RokToken();
    uint value = 0;
    address spender = 0xe241ed8Fe29a6835D4d780f7cC1fb2b3Fb60614C;
    rok.setAllowance(this, spender, value);
    rok.approve(spender,value);

    Assert.equal(rok.approve(spender,value), true, "Error approve");
  }

}
