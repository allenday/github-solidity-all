pragma solidity ^0.4.16;

import "wafr/Test.sol";
import "utils/MiniMeToken.sol";


contract TokenUser {
  MiniMeToken token;
  function () public payable {}

  function TokenUser(address _token) public {
    token = MiniMeToken(_token);
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    return token.transfer(_to, _value);
  }
}


contract MiniMeTokenTest is Test {
  MiniMeToken token;
  uint256 initGeneration = 5000;

  TokenUser user1;
  TokenUser user2;
  TokenUser user3;
  TokenUser user4;

  function setup() {
    token = new MiniMeToken(
        address(0),
        address(0),
        0,
        "MiniMeToken",
        8,
        "MMT",
        true);
    user1 = new TokenUser(address(token));
    user2 = new TokenUser(address(token));
    user3 = new TokenUser(address(token));
    user4 = new TokenUser(address(token));

    require(user1.send(100000000));
    require(user2.send(100000000));
    require(user3.send(100000000));
    require(user4.send(100000000));
  }

  function test_0_testGenerateTokens() {
    // test for balance
    assertEq(token.balanceOf(address(this)), 0);
    assertEq(token.balanceOfAt(address(this), block.number), 0);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), 0);
    assertEq(token.totalSupply(), 0);
    assertEq(token.totalSupplyAt(block.number), 0);
    assertEq(token.totalSupplyAt(block.timestamp), 0);

    // generate tokens
    assertEq(token.generateTokens(address(this), 5000), true);

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);

    // generate tokens
    assertEq(token.generateTokens(address(this), 5000), true);

    initGeneration += 5000;

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);

    // generate tokens
    assertEq(token.generateTokens(address(this), 5000), true);

    initGeneration += 5000;

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }

  function test_1_generationAcrossBlocks_increaseBlocksBy100() {
    // generate tokens
    assertEq(token.generateTokens(address(this), 5000), true);

    initGeneration += 5000;

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }

  function test_2_destroyTokens() {
    // generate tokens
    assertEq(token.destroyTokens(address(this), 5000), true);

    initGeneration -= 5000;

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);

    // generate tokens
    assertEq(token.destroyTokens(address(this), 5000), true);

    initGeneration -= 5000;

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }

  function test_3_destoryTokensAccrossBlocks_increaseBlocksBy1000() {
    // generate tokens
    assertEq(token.destroyTokens(address(this), 300), true);

    initGeneration -= 300;

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }

  function test_4_generateTokensAccrossBlocksAfterDestroy_increaseBlocksBy1000() {
    // generate tokens
    assertEq(token.generateTokens(address(this), 2340), true);

    initGeneration += 2340;

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }

  function test_5_generateSecondAccountBalance_increaseBlocksBy1000() {
    address secondAccount = address(sha3("something"));
    uint secondAccountGen = 1000;

    // generate tokens
    assertEq(token.generateTokens(secondAccount, secondAccountGen), true);

    // test for balance
    assertEq(token.balanceOf(address(this)), initGeneration);
    assertEq(token.balanceOfAt(address(this), block.number), initGeneration);
    assertEq(token.balanceOfAtTime(address(this), block.timestamp), initGeneration);

    // up generation then do total supply
    initGeneration += secondAccountGen;

    // test total supply
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);

    // test for balance
    assertEq(token.balanceOf(secondAccount), secondAccountGen);
    assertEq(token.balanceOfAt(secondAccount, block.number), secondAccountGen);
    assertEq(token.balanceOfAtTime(secondAccount, block.timestamp), secondAccountGen);
  }

  function test_6_basicTransfer_increaseBlocksBy1000() {
    address thirdAccount = address(sha3("anotherAccount"));
    uint256 initThirdAccount = 0;

    // test for balance
    assertEq(token.balanceOf(thirdAccount), initThirdAccount);
    assertEq(token.balanceOfAt(thirdAccount, block.number), initThirdAccount);
    assertEq(token.balanceOfAtTime(thirdAccount, block.timestamp), initThirdAccount);

    // transfer from address(this) to third account
    assertEq(token.transfer(thirdAccount, 500), true);

    initThirdAccount += 500;

    // test for balance
    assertEq(token.balanceOf(thirdAccount), initThirdAccount);
    assertEq(token.balanceOfAt(thirdAccount, block.number), initThirdAccount);
    assertEq(token.balanceOfAtTime(thirdAccount, block.timestamp), initThirdAccount);

    // test total supply
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }

  function test_8_basicTransfersBetweenAccounts_increaseBlocksBy300() {
    address user1Address = address(user1);
    address user2Address = address(user2);

    // test for balance
    assertEq(token.balanceOf(user1Address), 0);
    assertEq(token.balanceOfAt(user1Address, block.number), 0);
    assertEq(token.balanceOfAtTime(user1Address, block.timestamp), 0);

    // transfer from address(this) to third account
    assertEq(token.transfer(user1Address, 500), true);

    // test for balance
    assertEq(token.balanceOf(user1Address), 500);
    assertEq(token.balanceOfAt(user1Address, block.number), 500);
    assertEq(token.balanceOfAtTime(user1Address, block.timestamp), 500);

    // transfer from address(this) to third account
    assertEq(user1.transfer(user2Address, 500), true);

    // test for balance
    assertEq(token.balanceOf(user1Address), 0);
    assertEq(token.balanceOfAt(user1Address, block.number), 0);
    assertEq(token.balanceOfAtTime(user1Address, block.timestamp), 0);

    // test for balance
    assertEq(token.balanceOf(user2Address), 500);
    assertEq(token.balanceOfAt(user2Address, block.number), 500);
    assertEq(token.balanceOfAtTime(user2Address, block.timestamp), 500);

    // transfer from address(this) to third account
    assertEq(user2.transfer(user1Address, 500), true);

    // test for balance
    assertEq(token.balanceOf(user1Address), 500);
    assertEq(token.balanceOfAt(user1Address, block.number), 500);
    assertEq(token.balanceOfAtTime(user1Address, block.timestamp), 500);

    // test for balance
    assertEq(token.balanceOf(user2Address), 0);
    assertEq(token.balanceOfAt(user2Address, block.number), 0);
    assertEq(token.balanceOfAtTime(user2Address, block.timestamp), 0);

    // test total supply
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }

  function test_9_checkDestructionOverflow_shouldThrow() {
    address user4Address = address(user4);
    assertEq(token.destroyTokens(user4Address, 500), true);
  }

  function test_9a_transferShouldBeFalse() {
    assertEq(user4.transfer(address(user1), 3290390390), false);

    // test total supply
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }

  function test_9b_testGoodTransfer_thenInvalid() {
    assertEq(user1.transfer(address(user1), 2), true);
    assertEq(user1.transfer(address(user1), 23498243892349), false);

    // test total supply
    assertEq(token.totalSupply(), initGeneration);
    assertEq(token.totalSupplyAt(block.number), initGeneration);
    assertEq(token.totalSupplyAt(block.timestamp), initGeneration);
  }
}
