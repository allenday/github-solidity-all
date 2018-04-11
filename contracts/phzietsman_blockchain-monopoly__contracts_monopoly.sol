pragma solidity ^0.4.13;

contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }

}

contract Bank is Owned {
    address public bankManager;
		uint256 public bankBalance = 0;

    function Bank() {
        owner = msg.sender;
    }

    modifier onlyBankManager {
        require(msg.sender == bankManager);
        _;
    }

    function newBankManager(address newManager) onlyOwner {
        bankManager = newManager;
    }

    
}

contract MonopolyGame {
    mapping (address => MonopolyBank) public games;

    function newGame (string tokenName, string tokenSymbol) {
        uint256 monopolyTotalMoneyValue = 15140;
        uint8 decimals = 0;

        MonopolyBank newGameAddress = new MonopolyBank(monopolyTotalMoneyValue, tokenName, decimals, tokenSymbol, msg.sender);
        games[msg.sender] = newGameAddress;
    } 
}

contract MonopolyBank is Owned, Bank {

		// Standard Token variables
    /* Public variables of the token */
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
   
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

		// Monopoly Spesific
    uint256 public finesBalance = 0;
		
		struct FineClaim {
			address to;
			bool approved;
			uint expiretime;
		}

		FineClaim public activeFineClaim;

		string[] public charms = [
			"Battleship",
			"Boot",
      "Scottie",
      "Iron",
      "Racecar",
    	"Hat",
      "Thimble",
      "Wheelbarrow"
		];

		mapping (string => bool) _charms;
    mapping (string => address) charmToOwner;
		mapping (address => string) public ownerToCharm;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(string from, address indexed to, uint256 value);
		event Paid(string from, string to, uint256 value);
		event ClaimFines(string who);

    function MonopolyBank(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        address ownerNew
    ) {
        bankBalance = initialSupply;                        // Update total supply
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes

        // msg.sender in this context is not the same as in the MonopolyGame context,
        // since this contract gets executed from the MonopolyGame address, the sender is 
        // MonopolyGame.
				transferOwnership(ownerNew);
        newBankManager(ownerNew);

				// This looks stupid, but it is way cheaper than 
				// doing this every time you need to check a charm name
				for (uint i = 0; i < charms.length; i++) {
					_charms[charms[i]] = true;
				}
    }

		function resetGame() onlyOwner {
			for (uint i = 0; i < charms.length; i++) {
				
				address toDelete = charmToOwner[charms[i]];
				ownerToCharm[toDelete] = "Deleted";
				charmToOwner[charms[i]] = 0x0;
				balanceOf[toDelete] = 0;
			}

			bankBalance = totalSupply;
			finesBalance = 0;
			newBankManager(owner);
		}

		// The owner must be the bank manager to do this
		// true after a reset
		function assignPlayer(string charm, address to) onlyOwner {
			require(_validCharm(charm));
			ownerToCharm[to] = charm;
			charmToOwner[charm] = to;
			bankToCharm(charm, 1500);
		}

		modifier onlyPlayers {
				require(_validCharm(ownerToCharm[msg.sender]));
        _;
    }

		function _validCharm(string charmName) internal returns (bool isValid) {
        isValid = _charms[charmName];
				return isValid;
    }
    

		/* Internal transfer, only can be called by this contract */
    function _transfer(address _from, string _fromCharm, address _to, string _toCharm, uint _value) internal {
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(_fromCharm, _to, _value);
				Paid(_fromCharm, _toCharm, _value);
    }


		// Players only paying
		// ============================================
		function payToCharm(string toCharmName, uint256 value) onlyPlayers {
			require(_validCharm(toCharmName));
			_transfer(msg.sender, ownerToCharm[msg.sender], charmToOwner[toCharmName], toCharmName, value);
		}

		function payToBank(uint256 value) onlyPlayers {

      require (balanceOf[msg.sender] > value);                				// Check if the sender has enough
      require (bankBalance + value > bankBalance); 			// Check for overflows
      balanceOf[msg.sender] -= value;                         	// Subtract from the sender
      bankBalance += value;                            	// Add the same to the recipient
      Paid(ownerToCharm[msg.sender], "Bank", value);			
		}

		function payToFines(uint256 value) onlyPlayers {

      require (balanceOf[msg.sender] > value);                				// Check if the sender has enough
      require (finesBalance + value > finesBalance); 			// Check for overflows
      balanceOf[msg.sender] -= value;                         	// Subtract from the sender
      finesBalance += value;                            	// Add the same to the recipient
      Paid(ownerToCharm[msg.sender], "Fines", value);			
		}

		// Bank paying
		// ============================================
		function bankToCharm(string toCharmName, uint256 value) onlyBankManager {
			require(_validCharm(toCharmName));

			address to = charmToOwner[toCharmName];

      require (bankBalance > value);                				// Check if the sender has enough
      require (balanceOf[to] + value > balanceOf[to]); 			// Check for overflows
      bankBalance -= value;                         	// Subtract from the sender
      balanceOf[to] += value;                            	// Add the same to the recipient
      Transfer("Bank", to, value);
			Paid("Bank", toCharmName, value);	
		}

		// Fines
		//  ============================================
		function claimFine() onlyPlayers {
			// No active claim
			require(activeFineClaim.approved == true || now > activeFineClaim.expiretime);
			
			activeFineClaim = FineClaim({
				to: msg.sender,
				approved: false,
				expiretime: now + 5 minutes
			});			

			ClaimFines(ownerToCharm[msg.sender]);
		}

		function releaseFine() onlyPlayers {
	
			require(activeFineClaim.approved != true || now < activeFineClaim.expiretime);
			require(activeFineClaim.to != msg.sender);


			string storage to = ownerToCharm[activeFineClaim.to];
			uint256 value = finesBalance;

      require (balanceOf[activeFineClaim.to] + finesBalance > balanceOf[activeFineClaim.to]); 			// Check for overflows
      balanceOf[activeFineClaim.to] += finesBalance;                            	// Add the same to the recipient
      finesBalance = 0;                         								// Subtract from the sender

			activeFineClaim.approved = true;

      Transfer("Fines", activeFineClaim.to, value);
			Paid("Fines", to, value);	
		}

}