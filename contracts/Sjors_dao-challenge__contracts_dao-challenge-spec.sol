import 'dapple/test.sol';
import '../contracts/dao-challenge.sol';

contract User {

  function buyTokens (DaoChallenge chal, uint256 n) returns (uint256) {
    return chal.buyTokens.value(n * chal.tokenPrice())();
  }

  function placeSellOrder (DaoChallenge chal, uint256 n, uint256 price) returns (SellOrder) {
    return chal.placeSellOrder(n, price);
  }

  function cancelSellOrder (DaoChallenge chal, address addr) {
    chal.cancelSellOrder(addr);
  }

  function executeSellOrder (DaoChallenge chal, address addr, uint256 amount) {
    chal.executeSellOrder.value(amount)(addr);
  }

  function getTokenBalance (DaoChallenge chal) returns (uint256) {
    return chal.getTokenBalance();
  }

  function getAccountBalance (DaoChallenge chal) returns (uint256) {
    return chal.getBalance();
  }
}

contract DaoChallengeTest is Test {
    DaoChallenge chal;
    Tester proxy_tester;

    User userA;
    User userB;

    function setUp() {
        chal = new DaoChallenge();

        userA = new User();
        if(!userA.send(50)) throw; // Fund User A with 50 wei

        userB = new User();
        if(!userB.send(50)) throw; // Fund User B with 50 wei

        proxy_tester = new Tester();
        proxy_tester._target(chal);
    }
}

contract DaoChallengeConstructorTest is DaoChallengeTest {

    function testStoresChallengeOwner() {
        assertEq( address(this), chal.challengeOwner() );
    }

    function testInitialEtherBalanceShouldBeZero() {
      assertEq( chal.balance, 0 );
    }

}

contract DaoChallengeIssueTokensTest is DaoChallengeTest {
  function testIssueTokens () {
    // Issue 1000 tokens at 1 szabo each, sale ends in the year 3000.
    chal.issueTokens(1000, 1, 32503680000);
    assertEq(chal.tokenPrice(), 1);
  }
}

contract DaoChallengeGetAccountBalanceTest is DaoChallengeTest {
  function testGetAccountBalance () {
    chal.issueTokens(10, 2, 32503680000);
    userA.buyTokens(chal, 10);
    assertEq(userA.getAccountBalance(chal), 20);
  }
}

contract DaoChallengeBuyTokensTest is DaoChallengeTest {
  function setUp() {
    super.setUp();

    // Issue 1000 tokens at 1 szabo each, sale ends in the year 3000.
    chal.issueTokens(1000, 1, 32503680000);
  }

  function testBuyTenTokens () {
    userA.buyTokens(chal, 10);
    assertEq(userA.getTokenBalance(chal), 10);
  }
}

contract DaoChallengePlaceSellOrderTest is DaoChallengeTest {
  function setUp() {
    super.setUp();

    // Challenge owner issues tokens, user A buys 10:
    chal.issueTokens(1000, 1, 32503680000);
    userA.buyTokens(chal, 10);
  }

  function testSellTwoTokens () {
    // Offer to sell 2 tokens for 1 finney each
    userA.placeSellOrder(chal, 2, 1000);
  }
}

contract DaoChallengeCancelSellOrderTest is DaoChallengeTest {
  SellOrder order;

  function setUp() {
    super.setUp();

    // Challenge owner issues tokens, user A buys 10:
    chal.issueTokens(1000, 1, 32503680000);
    userA.buyTokens(chal, 10);

    // Place a sell order
    order = userA.placeSellOrder(chal, 2, 1000);
  }

  function testCancelSellOrder () {
    userA.cancelSellOrder(chal, address(order));
    assertEq(userA.getTokenBalance(chal), 10);
  }

  function testThrowCancelSellOrderTwice () {
    userA.cancelSellOrder(chal, address(order));
    userA.cancelSellOrder(chal, address(order));
  }
}

contract DaoChallengeExecuteSellOrderTest is DaoChallengeTest {
  SellOrder order;

  function setUp() {
    super.setUp();

    // Challenge owner issues tokens, user A buys 10:
    chal.issueTokens(1000, 1, 32503680000);
    userA.buyTokens(chal, 10);

    // Place a sell order
    order = userA.placeSellOrder(chal, 2, 15);
  }

  function testExecuteSellOrder () {
    userB.executeSellOrder(chal, address(order), 30);
  }

  // Implictly tests that a sell order is deleted:
  function testThrowExecuteSellOrderTwice () {
    userA.executeSellOrder(chal, address(order), 30);
    userA.executeSellOrder(chal, address(order), 30);
  }

  function testExecuteSellOrderShouldIncreaseBuyerTokens () {
    userB.executeSellOrder(chal, address(order), 30);
    assertEq(userB.getTokenBalance(chal), 2);
  }

  function testExecuteSellOrderShouldIncreaseSellerBalance () {
    uint256 before = userA.getAccountBalance(chal);
    userB.executeSellOrder(chal, address(order), 30);
    assertEq(userA.getAccountBalance(chal), before + 30 );
  }

  // Sell Order execution is paid for by buyer in the transaction, not
  // taken from their balance.
  function testExecuteSellOrderShouldNotChangeBuyerBalance () {
    // Create an account for User B first:
    userB.buyTokens(chal, 1);

    uint256 before = userB.getAccountBalance(chal);
    userB.executeSellOrder(chal, address(order), 30);
    assertEq(userB.getAccountBalance(chal), before);
  }

  function testThrowExecuteSellOrderDaoChallengeRefusesZeroFunds () {
    userB.executeSellOrder(chal, address(order), 0);
  }

  function testThrowExecuteSellOrderChecksAmount () {
    userB.executeSellOrder(chal, address(order), 31);
  }
}
