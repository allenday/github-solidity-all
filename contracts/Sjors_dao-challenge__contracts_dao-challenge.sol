import "./dao-account.sol";

contract DaoChallenge
{
	/**************************
					Constants
	***************************/


	/**************************
					Events
	***************************/

	event notifyTerminate(uint256 finalBalance);
	event notifyTokenIssued(uint256 n, uint256 price, uint deadline);

	event notifyNewAccount(address owner, address account);
	event notifyBuyToken(address owner, uint256 tokens, uint256 price);
	event notifyTransfer(address owner, address recipient, uint256 tokens);
  event notifyPlaceSellOrder(uint256 tokens, uint256 price);
  event notifyCancelSellOrder();
  event notifyExecuteSellOrder(uint256 tokens, uint256 price);

	/**************************
	     Public variables
	***************************/

	// For the current token issue:
	uint public tokenIssueDeadline = now;
	uint256 public tokensIssued = 0;
	uint256 public tokensToIssue = 0;
	uint256 public tokenPrice = 1000000000000000; // 1 finney

	mapping (address => DaoAccount) public daoAccounts;
  mapping (address => SellOrder) public sellOrders;

  // Owner of the challenge; a real DAO doesn't an owner.
  address public challengeOwner;

	/**************************
			 Private variables
	***************************/

	/**************************
					 Modifiers
	***************************/

	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

	/**************************
	 Constructor and fallback
	**************************/

	function DaoChallenge () {
		challengeOwner = msg.sender; // Owner of the challenge. Don't use this in a real DAO.
	}

	function () noEther {
	}

	/**************************
	     Private functions
	***************************/

	function accountFor (address accountOwner, bool createNew) private returns (DaoAccount) {
		DaoAccount account = daoAccounts[accountOwner];

		if(account == DaoAccount(0x00) && createNew) {
			account = new DaoAccount(accountOwner, challengeOwner);
			daoAccounts[accountOwner] = account;
			notifyNewAccount(accountOwner, address(account));
		}

		return account;
	}

	/**************************
	     Public functions
	***************************/

	function createAccount () {
		accountFor(msg.sender, true);
	}

	// Check if a given account belongs to this DaoChallenge.
	function isMember (DaoAccount account, address allegedOwnerAddress) returns (bool) {
		if (account == DaoAccount(0x00)) return false;
		if (allegedOwnerAddress == 0x00) return false;
		if (daoAccounts[allegedOwnerAddress] == DaoAccount(0x00)) return false;
		// allegedOwnerAddress is passed in for performance reasons, but not trusted
		if (daoAccounts[allegedOwnerAddress] != account) return false;
		return true;
	}

  function getBalance () constant noEther returns (uint256) {
    DaoAccount account = accountFor(msg.sender, false);
    if (account == DaoAccount(0x00)) return 0;
    return account.balance;
  }

	function getTokenBalance () constant noEther returns (uint256 tokens) {
		DaoAccount account = accountFor(msg.sender, false);
		if (account == DaoAccount(0x00)) return 0;
		return account.getTokenBalance();
	}

	// n: max number of tokens to be issued
	// price: in wei, e.g. 1 finney = 0.001 eth = 1000000000000000 wei
	// deadline: unix timestamp in seconds
	function issueTokens (uint256 n, uint256 price, uint deadline) noEther onlyChallengeOwner {
		// Only allow one issuing at a time:
		if (now < tokenIssueDeadline) throw;

		// Deadline can't be in the past:
		if (deadline < now) throw;

		// Issue at least 1 token
		if (n == 0) throw;

		tokenPrice = price;
		tokenIssueDeadline = deadline;
		tokensToIssue = n;
		tokensIssued = 0;

		notifyTokenIssued(n, price, deadline);
	}

	function buyTokens () returns (uint256 tokens) {
		tokens = msg.value / tokenPrice;

		if (now > tokenIssueDeadline) throw;
		if (tokensIssued >= tokensToIssue) throw;

		// This hopefully prevents issuing too many tokens
		// if there's a race condition:
		tokensIssued += tokens;
		if (tokensIssued > tokensToIssue) throw;

	  DaoAccount account = accountFor(msg.sender, true);
		if (account.buyTokens.value(msg.value)() != tokens) throw;

		notifyBuyToken(msg.sender, tokens, msg.value);
		return tokens;
 	}

	function transfer(uint256 tokens, address recipient) noEther {
		DaoAccount account = accountFor(msg.sender, false);
		if (account == DaoAccount(0x00)) throw;

		DaoAccount recipientAcc = accountFor(recipient, false);
		if (recipientAcc == DaoAccount(0x00)) throw;

		account.transfer(tokens, recipientAcc);
		notifyTransfer(msg.sender, recipient, tokens);
	}

  function placeSellOrder(uint256 tokens, uint256 price) noEther returns (SellOrder) {
    DaoAccount account = accountFor(msg.sender, false);
    if (account == DaoAccount(0x00)) throw;

    SellOrder order = account.placeSellOrder(tokens, price);

    sellOrders[address(order)] = order;

    notifyPlaceSellOrder(tokens, price);
    return order;
  }

  function cancelSellOrder(address addr) noEther {
    DaoAccount account = accountFor(msg.sender, false);
    if (account == DaoAccount(0x00)) throw;

    SellOrder order = sellOrders[addr];
    if (order == SellOrder(0x00)) throw;

    if (order.owner() != address(account)) throw;

    sellOrders[addr] = SellOrder(0x00);

    account.cancelSellOrder(order);

    notifyCancelSellOrder();
  }

  function executeSellOrder(address addr) {
    // Fefuse if no ether is sent. SellOrder checks the exact amount.
    if (msg.value == 0) throw;

    DaoAccount account = accountFor(msg.sender, true);

    SellOrder order = sellOrders[addr];
    if (order == SellOrder(0x00)) throw;

    // Don't execute your own oder:
    if (order.owner() == address(account)) throw;

    uint256 tokens = order.tokens();
    uint256 price = order.price();

    // If order is successful, forget it (might not be necessary)
    sellOrders[addr] = SellOrder(0x00);

    account.executeSellOrder.value(msg.value)(order);

    notifyExecuteSellOrder(tokens, price);
  }

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyChallengeOwner {
		notifyTerminate(this.balance);
		suicide(challengeOwner);
	}
}
