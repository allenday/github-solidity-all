pragma solidity ^0.4.16;

import "wafr/Test.sol";
import "utils/DefaultRules.sol";


contract DefaultRulesTest is Test {
  DefaultRules rules;

  function setup() {
    rules = new DefaultRules();
  }

  function test_0_ensureDefaultRulesSetToFalse() {
    assertEq(rules.canPropose(msg.sender, 0), false);
    assertEq(rules.canVote(msg.sender, 0), false);
    assertEq(rules.canExecute(msg.sender, 0), false);
    assertEq(rules.votingWeightOf(msg.sender, 0, 0, 0), uint256(0));
  }
}
