contract SellOrder {
  /**************************
          Constants
  ***************************/

  /**************************
          Events
  ***************************/

  /**************************
       Public variables
  ***************************/

  // Owner of the challenge with backdoor access.
  // Remove for a real DAO contract:
  address public challengeOwner;
  address public owner; // DaoAccount that created the order
  uint256 public tokens;
  uint256 public price; // Wei per token

  /**************************
       Private variables
  ***************************/


  /**************************
           Modifiers
  ***************************/

  modifier noEther() {if (msg.value > 0) throw; _}

  modifier onlyOwner() {if (owner != msg.sender) throw; _}

  modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

  /**************************
   Constructor and fallback
  **************************/

  function SellOrder (uint256 _tokens, uint256 _price, address _challengeOwner) noEther {
    owner = msg.sender;

    tokens = _tokens;
    price = _price;

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

  function cancel () noEther onlyOwner {
    suicide(owner);
  }

  function execute () {
    if (msg.value != tokens * price) throw;

    // Tokens are sent to the buyer in DaoAccount.executeSellOrder()
    // Send ether to seller:
    suicide(owner);
  }

  // The owner of the challenge can terminate it. Don't use this in a real DAO.
  function terminate() noEther onlyChallengeOwner {
    suicide(challengeOwner);
  }
}
