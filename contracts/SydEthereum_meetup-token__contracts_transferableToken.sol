/*
An ERC20 compliant token that is linked to an external identifier. For exmaple, Meetup.com

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.
*/

pragma solidity ^0.4.15;

contract ERC20Token
{
/* State */
    // The Total supply of tokens
    uint256 totSupply;
    
    /// @return Token symbol
    string sym;
    string nam;

    uint8 public decimals = 0;
    
    // Token ownership mapping
    mapping (address => uint256) balances;
    
    // Allowances mapping
    mapping (address => mapping (address => uint256)) allowed;

/* Events */
    // Triggered when tokens are transferred.
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value);

/* Funtions Public */

    function symbol() public constant returns (string)
    {
        return sym;
    }

    function name() public constant returns (string)
    {
        return nam;
    }
    
    // Using an explicit getter allows for function overloading    
    function totalSupply() public constant returns (uint256)
    {
        return totSupply;
    }
    
    // Using an explicit getter allows for function overloading    
    function balanceOf(address holderAddress) public constant returns (uint256 balance)
    {
        return balances[holderAddress];
    }
    
    // Using an explicit getter allows for function overloading    
    function allowance(address ownerAddress, address spenderAddress) public constant returns (uint256 remaining)
    {
        return allowed[ownerAddress][spenderAddress];
    }
        

    // Send amount amount of tokens to address _to
    function transfer(address toAddress, uint256 amount) public returns (bool success)
    {
        return xfer(msg.sender, toAddress, amount);
    }

    // Send amount amount of tokens from address _from to address _to
    function transferFrom(address fromAddress, address toAddress, uint256 amount) public returns (bool success)
    {
        require(amount <= allowed[fromAddress][msg.sender]);
        allowed[fromAddress][msg.sender] -= amount;
        xfer(fromAddress, toAddress, amount);
        return true;
    }

    // Process a transfer internally.
    function xfer(address fromAddress, address toAddress, uint amount) internal returns (bool success)
    {
        require(amount <= balances[fromAddress]);
        balances[fromAddress] -= amount;
        balances[toAddress] += amount;
        Transfer(fromAddress, toAddress, amount);
        return true;
    }

    // Approves a third-party spender
    function approve(address spender, uint256 value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((value == 0) || (allowed[msg.sender][spender] == 0));

        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    /**
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until 
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    */
    function increaseApproval (address spender, uint addedValue) returns (bool success)
    {
        allowed[msg.sender][spender] = allowed[msg.sender][spender] + addedValue;
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseApproval (address spender, uint subtractedValue) returns (bool success)
    {
        uint oldValue = allowed[msg.sender][spender];

        if (subtractedValue > oldValue) {
            allowed[msg.sender][spender] = 0;
        } else {
            allowed[msg.sender][spender] = oldValue - subtractedValue;
        }
        Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
}

contract TransferableMeetupToken is ERC20Token
{
    address owner = msg.sender;
    
    function TransferableMeetupToken(string tokenSymbol, string toeknName)
    {
        sym = tokenSymbol;
        nam = toeknName;
    }
    
    event Issue(
        address indexed toAddress,
        uint256 amount,
        string externalId,
        string reason);

    event Redeem(
        address indexed fromAddress,
        uint256 amount);

    function issue(address toAddress, uint amount, string externalId, string reason) public returns (bool)
    {
        require(owner == msg.sender);
        totSupply += amount;
        balances[toAddress] += amount;
        Issue(toAddress, amount, externalId, reason);
        Transfer(0x0, toAddress, amount);
        return true;
    }
    
    function redeem(uint amount) public returns (bool)
    {
        require(balances[msg.sender] >= amount);
        totSupply -= amount;
        balances[msg.sender] -= amount;
        Redeem(msg.sender, amount);
        Transfer(msg.sender, 0x0, amount);
        return true;
    }
}