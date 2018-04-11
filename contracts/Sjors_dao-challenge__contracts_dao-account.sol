import "./sell-order.sol";

contract AbstractDaoChallenge {
	function isMember (DaoAccount account, address allegedOwnerAddress) returns (bool);
	function tokenPrice() returns (uint256);
}

contract DaoAccount
{
	/**************************
			    Constants
	***************************/

	/**************************
					Events
	***************************/

	// No events

	/**************************
	     Public variables
	***************************/

	address public daoChallenge; // the DaoChallenge this account belongs to

	// Owner of the challenge with backdoor access.
  // Remove for a real DAO contract:
  address public challengeOwner;

	/**************************
	     Private variables
	***************************/

	uint256 tokenBalance; // number of tokens in this account
  address owner;        // owner of the tokens

	/**************************
			     Modifiers
	***************************/

	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyOwner() {if (owner != msg.sender) throw; _}

	modifier onlyDaoChallenge() {if (daoChallenge != msg.sender) throw; _}

	modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

	/**************************
	 Constructor and fallback
	**************************/

  function DaoAccount (address _owner, address _challengeOwner) noEther {
    owner = _owner;
    daoChallenge = msg.sender;
		tokenBalance = 0;

    // Remove for a real DAO contract:
    challengeOwner = _challengeOwner;
	}

	function () {
		throw;
	}

	/**************************
	     Private functions
	***************************/

	/**************************
			 Public functions
	***************************/

	function getOwnerAddress() constant returns (address ownerAddress) {
		return owner;
	}

	function getTokenBalance() constant returns (uint256 tokens) {
		return tokenBalance;
	}

	function buyTokens() onlyDaoChallenge returns (uint256 tokens) {
		uint256 amount = msg.value;
		uint256 tokenPrice = AbstractDaoChallenge(daoChallenge).tokenPrice();

		// No free tokens:
		if (amount == 0) throw;

		// No fractional tokens:
		if (amount % tokenPrice != 0) throw;

		tokens = amount / tokenPrice;

		tokenBalance += tokens;

		return tokens;
	}

	function transfer(uint256 tokens, DaoAccount recipient) noEther onlyDaoChallenge {
		if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
		if (tokenBalance - tokens > tokenBalance) throw; // Overflow
		tokenBalance -= tokens;
		recipient.receiveTokens(tokens);
	}

	function receiveTokens(uint256 tokens) {
		// Check that the sender is a DaoAccount and belongs to our DaoChallenge
		DaoAccount sender = DaoAccount(msg.sender);
		if (!AbstractDaoChallenge(daoChallenge).isMember(sender, sender.getOwnerAddress())) throw;

		if (tokens > sender.getTokenBalance()) throw;

		// Protect against overflow:
		if (tokenBalance + tokens < tokenBalance) throw;

		tokenBalance += tokens;
	}

  function placeSellOrder(uint256 tokens, uint256 price) noEther onlyDaoChallenge returns (SellOrder) {
    if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
    if (tokenBalance - tokens > tokenBalance) throw; // Overflow
    tokenBalance -= tokens;

    SellOrder order = new SellOrder(tokens, price, challengeOwner);
    return order;
  }

  function cancelSellOrder(SellOrder order) noEther onlyDaoChallenge {
    uint256 tokens = order.tokens();
    tokenBalance += tokens;
    order.cancel();
  }

  function executeSellOrder(SellOrder order) onlyDaoChallenge {
    uint256 tokens = order.tokens();
    tokenBalance += tokens;
    order.execute.value(msg.value)();
  }

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyChallengeOwner {
		suicide(challengeOwner);
	}
}
