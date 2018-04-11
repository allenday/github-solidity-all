pragma solidity ^0.4.18;


contract TestTokenConfig {

}

library SafeMath {

    // a * b
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    // a div b
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        return c;
    }

    // a - b
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    // a + b
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract ReentryProtected {

    // The reentry protection state mutex.
    bool private reentrancy_lock = false;

    // Sets and resets mutex in order to block function reentry
    modifier preventReentry() {
        require(!reentrancy_lock);
        reentrancy_lock = true;
        _;
        delete reentrancy_lock;
    }

    // Blocks function entry if mutex is set
    modifier noReentry() {
        require(!reentrancy_lock);
        _;
    }
}


contract Ownable is ReentryProtected {

    // Current owner must be set manually
    address public owner;

    // An address authorised to take ownership
    address public newOwner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() internal {
        owner = 0xe1318D2092c1F9731cb316d4EB3cF268A8147D00;
    }

    // Only Owner can call
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // To initiate an ownership change
    function changeOwner(address _newOwner) public
    noReentry
    onlyOwner
    returns (bool)
    {
        ChangeOwnerTo(_newOwner);
        newOwner = _newOwner;
        return true;
    }

    // To claim ownership. Required to prove new address can call the contract.
    function claimOwnership() public
    noReentry
    returns (bool)
    {
        require(msg.sender == newOwner);
        ChangedOwner(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
        return true;
    }


    /**********************
    * Events
    ***********************/

    // Logged when owner initiates a change of ownership
    event ChangeOwnerTo(address indexed _to);

    // Logged when new owner accepts ownership
    event ChangedOwner(address indexed _from, address indexed _to);

    /**********************
    * Change Owner
    ***********************/
}


contract ERC20 {

    // Automatically creates a getter function for the totalSupply
    // Total Supply
    uint256 public totalSupply;

    // Optional ERC20
    // Token Name
    // string public constant name = "Full Name";

    // Token Decimal places
    // uint8 public constant decimals = 18;

    // Token Symbol Short 3+ letters
    // string public constant symbol = "FNT";

    // @param who The address from which the balance will be retrieved
    // @return The balance
    function balanceOf(address who) public constant returns (uint256);

    // @notice send `value` token to `to` from `msg.sender`
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transfer(address to, uint256 value) public returns (bool);

    // @notice send `value` token to `to` from `from` on the condition it is approved by `from`
    // @param from The address of the sender
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint256 value) public returns (bool);

    // @notice `msg.sender` approves `spender` to spend `value` tokens
    // @param `spender` The address of the account able to transfer the tokens
    // @param `value` The amount of tokens to be approved for transfer
    // @return Whether the approval was successful or not
    function approve(address spender, uint256 value) public returns (bool);

    // @param owner The address of the account owning tokens
    // @param spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens allowed to spent
    function allowance(address owner, address spender) public constant returns (uint256);

    /**********************
    * Events
    ***********************/

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StdToken is ERC20 {

    using SafeMath for uint256;

    // Balance of each owner
    mapping (address => uint256) balances;

    // Allowance mapping
    mapping (address => mapping (address => uint256)) allowed;

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowed[_owner][_spender];
    }
}


contract MintToken is StdToken, Ownable {

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    /**********************
    * Events
    ***********************/
    event Mint(address indexed to, uint256 amount);

    event MintFinished();
}


contract TestToken is MintToken {

    // Optional ERC20
    // Token Name
    string public constant name = "Test Token";

    // Token Decimal places
    uint8 public constant decimals = 18;

    // Token Symbol Short 3+ letters
    string public constant symbol = "TTT";

    function TestToken() public {
        require(bytes(symbol).length > 0);
        require(bytes(name).length > 0);
        require(owner != 0x0);
        require(decimals > 0);
        totalSupply = 0;
    }
}