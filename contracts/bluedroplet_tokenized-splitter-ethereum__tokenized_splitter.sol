/**
 * @title TokenizedSplitter
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract TokenizedSplitter {

    struct Account {
        bool activated;
        uint248 tokens;
        uint cash;
    }

    mapping (address => Account) accounts;
    address[] accountAddresses;

    uint allocatedCash;

    string public name;
    string public symbol;
    uint8 public decimals = 0;
    uint public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function TokenizedSplitter(string tokenName, string tokenSymbol, uint248 tokenTotalSupply) {
        // Store the token metadata
        name = tokenName;
        symbol = tokenSymbol;
        totalSupply = tokenTotalSupply;
        // Give the contract creator all the tokens.
        accounts[msg.sender].activated = true;
        accounts[msg.sender].tokens = tokenTotalSupply;
        accountAddresses.push(msg.sender);
    }

    function allocateCash() {
        // Calculate the amount of ether deposited into this contract since this
        // function was last run.
        uint unallocatedCash = this.balance - allocatedCash;
        // If no ether needs to be allocated just return.
        if (unallocatedCash == 0) {
            return;
        }
        // Loop through all the token holders.
        for (uint i = 0; i < accountAddresses.length; i++) {
            // Get the storage address for this account.
            Account account = accounts[accountAddresses[i]];
            // Does this account have any tokens?
            if (account.tokens != 0) {
                // Increase the amount of ether this account by the amount of
                // unallocated ether in proportion to how many of the tokens the
                // account has. Integer division rounds down so a very small
                // amount of ether may be lost.
                account.cash += (unallocatedCash * account.tokens) / totalSupply;
            }
        }
        // Set the record of allocated cash to the current balance.
        allocatedCash = this.balance;
    }

    function cashout() external {
        // Process any deposited ether.
        allocateCash();
        // Get the storage address for the sender's account.
        Account account = accounts[msg.sender];
        // Send the ether to the specified address.
        msg.sender.send(account.cash);
        // Record this account as having no ether.
        account.cash = 0;
        // Set the record of allocated cash to the current balance.
        allocatedCash = this.balance;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        // Process any deposited ether.
        allocateCash();
        // Get the storage address for the sender and receiver's accounts.
        Account fromAccount = accounts[msg.sender];
        Account toAccount = accounts[_to];
        // Check there is sufficent balance and there is no overflow.
        if (fromAccount.tokens < _value || toAccount.tokens + _value < toAccount.tokens) {
            return false;
        }
        // Ensure the receiver has an activated account.
        if (toAccount.activated == false) {
            toAccount.activated = true;
            accountAddresses.push(_to);
        }
        // Update token balances.
        fromAccount.tokens -= uint248(_value);
        toAccount.tokens += uint248(_value);
        // Log the event.
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant external returns (uint256 balance) {
        balance = accounts[_owner].tokens;
    }

    function cashBalanceOf(address _owner) constant external returns (uint256 cash) {
        allocateCash();
        cash = accounts[msg.sender].cash;
    }

}
