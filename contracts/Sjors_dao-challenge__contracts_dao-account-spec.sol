import 'dapple/test.sol';
import '../contracts/dao-account.sol';

// Mock DaoChallenge with several test helper methods
contract DaoChallenge {
  address public challengeOwner;
  uint256 public tokenPrice = 1; // 1000000000000000; // 1 finney

  function DaoChallenge (address _challengeOwner) {
    challengeOwner = _challengeOwner;
  }

  function createAccount () returns (DaoAccount) {
    return new DaoAccount(msg.sender, challengeOwner);
  }

  function buyTokens (DaoAccount account) returns (uint256) {
    return account.buyTokens.value(msg.value)();
  }

  function transfer (DaoAccount origin, DaoAccount recipient, uint256 tokens) {
    origin.transfer(tokens, recipient);
  }

  function setTokenPrice (uint256 price) {
    tokenPrice = price;
  }

  function placeSellOrder (DaoAccount account, uint256 n, uint256 price) returns (SellOrder) {
    return account.placeSellOrder(n, price);
  }
}

contract User {
  DaoAccount public account;

  function createAccount (DaoChallenge chal) returns (DaoAccount) {
    account = chal.createAccount();
    return account;
  }
  function buyTokens (DaoChallenge chal, uint256 amount) returns (uint256) {
    return chal.buyTokens.value(amount)(account);
  }
  function transfer (DaoChallenge chal, User recipient, uint256 tokens) {
    chal.transfer(account, recipient.account(), tokens);
  }
  function placeSellOrder (DaoChallenge chal, uint256 n, uint256 price) returns (SellOrder) {
    return chal.placeSellOrder(account, n, price);
  }
}

contract DaoAccountTest is Test {
    DaoChallenge chal;
    DaoAccount acc;
    Tester proxy_tester;
    address challenge_owner = address(this);

    User userA;

    function setUp() {
        chal = new DaoChallenge(challenge_owner);
        uint256 mockFunds = 1000;

        userA = new User();
        if(!userA.send(mockFunds)) throw; // Fund User A
        acc = userA.createAccount(chal);

        proxy_tester = new Tester();
        proxy_tester._target(acc);
    }
}

contract DaoAccountConstructorTest is DaoAccountTest {

    function testStoresChallengeOwner() {
        assertEq( address(this), acc.challengeOwner() );
    }

    function testStoresParentChallenge() {
        assertEq( address(chal), acc.daoChallenge() );
    }

    function testStoresUser() {
        assertEq( address(userA), acc.getOwnerAddress() );
    }

    function testInitialTokenBalanceShouldBeZero() {
      assertEq( acc.getTokenBalance(), 0 );
    }

    function testInitialEtherBalanceShouldBeZero() {
      assertEq( acc.balance, 0 );
    }

}

contract DaoAccountBuyTokenTest is DaoAccountTest {
    function testBuyTwoTokens() {
      uint256 tokens = userA.buyTokens(chal, chal.tokenPrice() * 2);
      assertEq( tokens, 2 );
      assertEq( acc.getTokenBalance(), 2 );
      assertEq( acc.balance, chal.tokenPrice() * 2 );
    }

    function testThrowNoFreeTokens() {
      userA.buyTokens(chal, 0);
    }

    function testThrowNoPartialTokens() {
      userA.buyTokens(chal, chal.tokenPrice() / 2);
    }

    function testDifferentTokenPrice() {
      userA.buyTokens(chal, chal.tokenPrice()); // 1 token
      chal.setTokenPrice(3);
      userA.buyTokens(chal, 6); // 2 tokens
      assertEq( acc.getTokenBalance(), 3);
    }

}

contract DaoAccountTransferTest is DaoAccountTest {
  User userB;
  DaoAccount accB;

  function setUp() {
    super.setUp();

    // Buy ten tokens
    userA.buyTokens(chal, chal.tokenPrice() * 10);

    userB = new User();
    accB = userB.createAccount(chal);
  }

  function testTranferOneToken () {
    userA.transfer(chal, userB, 1);

    assertEq( acc.getTokenBalance(), 9);
    assertEq( accB.getTokenBalance(), 1);
  }

  function testThrowTranferTooManyTokens () {
    userA.transfer(chal, userB, 11);
  }

  function testThrowTranferZeroTokens () {
    userA.transfer(chal, userB, 0);
  }

  function testThrowTranferFromEmptyBalance () {
    // First send all tokens
    userA.transfer(chal, userB, 10);

    // This should throw:
    userA.transfer(chal, userB, 1);
  }
}

contract DaoAccountReceiveTokensTest is DaoAccountTest {
  function setUp() {
    super.setUp();


  }
}

contract DaoAccountPlaceSellOrderTest is DaoAccountTest {
  function setUp() {
    super.setUp();

    // Buy ten tokens
    userA.buyTokens(chal, chal.tokenPrice() * 10);
  }

  function testSellTwoTokens () {
    // Offer to sell 2 tokens for 10 wei each
    userA.placeSellOrder(chal, 2, 10);
    assertEq(acc.getTokenBalance(), 8);
  }
}
