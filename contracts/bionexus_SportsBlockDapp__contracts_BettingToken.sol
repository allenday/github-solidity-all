pragma solidity ^0.4.0;

/// @title Betting Token Contract
/// @author The Sports Block Team
/// @notice Betting Token contracts are created and owned by a bet contract.
/// Tokens represent shares of the jackpot.
contract BettingToken
{
    // map addresses to their balances
    mapping(address=>uint256) private balanceOf;

    // map index to addresses
    // This has to be done so you can iterate over all balances
    // when paying out the jackpot
    mapping(uint256=>address) private addressOfIndex;

    // Be careful. The first user has the index "0"
    // That makes it easier to iterate through all users
    // with a for-loop
    uint256 numberOfUsers = 0;

    // contract that owns this Token
    address public contractOwner;

    // Number of existing tokens
    uint256 public tokenSupply;

    // used for functions that can be called exclusivelly by
    // the owner
    modifier onlyOwner { if(msg.sender == contractOwner) _; }

    /// @notice Create a new BettingToken
    /// @dev Constructor setting the contractOwner
    function BettingToken()
    {
        contractOwner = msg.sender;
    }

    /// @dev See also the "addressOfIndex" and "numberOfUsers" attributes
    /// This function gives every user address an index so you can
    /// iterate through all the indices.
    /// @param userAddress The address to create a new index for
    function addUser(address userAddress) private
    {
        addressOfIndex[numberOfUsers] = userAddress;
        numberOfUsers += 1;
    }

    /// @notice Adds the specified amount of tokens to a given address
    /// and update the tokenSupply
    /// @param tokenReceiver The address to give the new Tokens to
    /// @param amount Amount of tokens to add
    function addTokens(address tokenReceiver, uint256 amount) onlyOwner()
    {
        if(balanceOf[tokenReceiver] == 0)
            addUser(tokenReceiver);
        balanceOf[tokenReceiver] += amount;
        tokenSupply += amount;
    }

    function getSupply() returns(uint256 supply)
    {
        return tokenSupply;
    }

    /// @notice Pay out the Eth stored in the contract proportional to the
    /// amount of Tokens a user holds.
    /// After the payout the contract will be destroyed!
    function payout() onlyOwner()
    {
        for(uint256 i = 0; i < numberOfUsers; i++)
        {
            uint256 payoutSize = (balanceOf[addressOfIndex[i]] * this.balance) / tokenSupply;
            // Checks whether the transaction can be completed
            // This prevents potential attackers from using fallback
            // functions
            if(!addressOfIndex[i].send(payoutSize))
            {
                throw;
            }
            // If an address is indexed twice this prevents it from
            // being paid twice
            balanceOf[addressOfIndex[i]] = 0;
        }
        kill();
    }

    /// @notice Destroys the contract
    function kill() onlyOwner()
    {
        selfdestruct(contractOwner);
    }
    
    /// @dev allows to send eth via send()
    function() payable
    {
    }
}
