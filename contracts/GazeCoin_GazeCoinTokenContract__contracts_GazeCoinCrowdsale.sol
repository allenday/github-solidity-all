pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------
// GZE 'GazeCoin' crowdsale and token contract
//
// Status      : Work in progress
// Deployed to : 
// Symbol      : GZE
// Name        : GazeCoin
// Total supply: Allocate as required
// Decimals    : 18
//
// Enjoy.
//
// (c) GazeCoin 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    uint public totalSupply;
    function balanceOf(address account) public constant returns (uint balance);
    function transfer(address to, uint value) public returns (bool success);
    function transferFrom(address from, address to, uint value)
        public returns (bool success);
    function approve(address spender, uint value) public returns (bool success);
    function allowance(address owner, address spender) public constant
        returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {

    // ------------------------------------------------------------------------
    // Current owner, and proposed new owner
    // ------------------------------------------------------------------------
    address public owner;
    address public newOwner;

    // ------------------------------------------------------------------------
    // Modifier to mark that a function can only be executed by the owner
    // ------------------------------------------------------------------------
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    // ------------------------------------------------------------------------
    // Constructor - assign creator as the owner
    // ------------------------------------------------------------------------
    function Owned() public {
        owner = msg.sender;
    }


    // ------------------------------------------------------------------------
    // Owner can initiate transfer of contract to a new owner
    // ------------------------------------------------------------------------
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }


    // ------------------------------------------------------------------------
    // New owner has to accept transfer of contract
    // ------------------------------------------------------------------------
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
    event OwnershipTransferred(address indexed from, address indexed to);
}


// ----------------------------------------------------------------------------
// Safe maths, borrowed from OpenZeppelin
// ----------------------------------------------------------------------------
library SafeMath {

    // ------------------------------------------------------------------------
    // Add a number to another number, checking for overflows
    // ------------------------------------------------------------------------
    function add(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }


    // ------------------------------------------------------------------------
    // Subtract a number from another number, checking for underflows
    // ------------------------------------------------------------------------
    function sub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }


    // ------------------------------------------------------------------------
    // Multiply two numbers
    // ------------------------------------------------------------------------
    function mul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }


    // ------------------------------------------------------------------------
    // Multiply one number by another number
    // ------------------------------------------------------------------------
    function div(uint a, uint b) pure internal returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals
// ----------------------------------------------------------------------------
contract GazeCoin is ERC20Interface, Owned {
    using SafeMath for uint;

    // ------------------------------------------------------------------------
    // Token parameters
    // ------------------------------------------------------------------------
    string public constant symbol = "GZE";
    string public constant name = "GazeCoin";
    uint8 public constant decimals = 18;
    uint public totalSupply = 0;

    uint public constant DECIMALSFACTOR = 10**uint(decimals);

    // ------------------------------------------------------------------------
    // Balances for each account
    // ------------------------------------------------------------------------
    mapping(address => uint) balances;

    // ------------------------------------------------------------------------
    // Owner of account approves the transfer tokens to another account
    // ------------------------------------------------------------------------
    mapping(address => mapping (address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function GazeCoin() public Owned() {
    }


    // ------------------------------------------------------------------------
    // Get the account balance of another account with address account
    // ------------------------------------------------------------------------
    function balanceOf(address account) public constant returns (uint balance) {
        return balances[account];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from owner's account to another account
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Allow spender to withdraw from your account, multiple times, up to the
    // value tokens. If this function is called again it overwrites the
    // current allowance with value.
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Spender of tokens transfer an tokens of tokens from the token owner's
    // balance to another account. The owner of the tokens must already
    // have approve(...)-d this transfer
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public
        returns (bool success)
    {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the number of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address owner, address spender ) public 
        constant returns (uint remaining)
    {
        return allowed[owner][spender];
    }


    // ------------------------------------------------------------------------
    // Mint coins for a single account
    // ------------------------------------------------------------------------
    function mint(address to, uint tokens) internal {
        require(to != 0x0 && tokens != 0);
        balances[to] = balances[to].add(tokens);
        totalSupply = totalSupply.add(tokens);
        Transfer(0x0, to, tokens);
    }


    /*
    // ------------------------------------------------------------------------
    // Mint coins for a multiple accounts
    // ------------------------------------------------------------------------
    function multiMint(address[] to, uint[] amount) onlyAdministrator {
        require(!sealed);
        require(to.length != 0);
        require(to.length == amount.length);
        for (uint i = 0; i < to.length; i++) {
            require(to[i] != 0x0);
            require(amount[i] != 0);
            balances[to[i]] = balances[to[i]].add(amount[i]);
            totalSupply = totalSupply.add(amount[i]);
            Transfer(0x0, to[i], amount[i]);
        }
    }
    */


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens)
      public onlyOwner returns (bool success)
    {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}


// ----------------------------------------------------------------------------
// GazeCoin Crowdsale
// ----------------------------------------------------------------------------
contract GazeCoinCrowdsale is GazeCoin {

    // ------------------------------------------------------------------------
    // Start Date
    //   > new Date('2017-11-13T07:00:00-08:00').getTime()/1000
    //   1510585200
    //   > new Date(1510585200 * 1000).toUTCString()
    //   "Mon, 13 Nov 2017 15:00:00 UTC"
    //   > > new Date(1510585200 * 1000).toString()
    //   "Tue, 14 Nov 2017 02:00:00 AEDT"
    // End Date
    //   Start Date + 7 days
    // ------------------------------------------------------------------------
    uint public constant START_DATE = 1510585200;
    uint public constant END_DATE = START_DATE + 7 days;

    // ------------------------------------------------------------------------
    // Minimum financing USD 2 million
    // Target financing USD 12 million
    // Hard cap USD 35 million
    // 1GZE = US$0.35
    //
    // Pre-sale discounts are offered for 35% to SAFT investors and 30% to 
    // strategic investors. The pre-sale closes 48 hrs before 
    // the public ICO starts.
    // ------------------------------------------------------------------------
    uint public constant USD_MINIMUM_GOAL = 2000000;
    uint public constant USD_HARD_CAP = 35000000;

    // ------------------------------------------------------------------------
    // 70 % distributed in sale
    // Advisors 5 %
    // Team 10 %
    // Contractors 5 %
    // User Growth Pool 10%
    // ------------------------------------------------------------------------
    address public constant WALLET_CROWDSALE = 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976;
    address public constant WALLET_ADVISORS = 0xa33a6c312D9aD0E0F2E95541BeED0Cc081621fd0;
    address public constant WALLET_TEAM = 0xa44a08d3F6933c69212114bb66E2Df1813651844;
    address public constant WALLET_CONTRACTORS = 0xa55A151Eb00fded1634D27D1127b4bE4627079EA;
    address public constant WALLET_GROWTH_POOL = 0xa66a85ede0CBE03694AA9d9dE0BB19c99ff55bD9;

    uint public constant PERCENT_ADVISORS = 5;
    uint public constant PERCENT_TEAM = 10;
    uint public constant PERCENT_CONTRACTORS = 5;
    uint public constant PERCENT_GROWTH_POOL = 10;
    uint public constant PERCENT_RESERVE = PERCENT_ADVISORS + PERCENT_TEAM +
        PERCENT_CONTRACTORS + PERCENT_GROWTH_POOL;

    // ------------------------------------------------------------------------
    // The whitelist
    // ------------------------------------------------------------------------
    mapping(address => uint) public whitelist;


    // TODO: Replace hard cap
    uint public constant ETH_HARD_CAP = 5 ether;

    // Tokens per 1,000 ETH
    uint public constant tokensPerKEther = 1000000; 

    // Keep track of ETH raised
    uint public ethersRaised;

    // Crowdsale finalised?
    bool public finalised;

    // Tokens transferable?
    bool public transferable;


    // ------------------------------------------------------------------------
    // Are the tokens transferable
    // ------------------------------------------------------------------------
    modifier isTransferable {
        require(transferable);
        _;
    }


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function GazeCoinCrowdsale() public GazeCoin() {
    }


    // ------------------------------------------------------------------------
    // Whitelist
    // ------------------------------------------------------------------------
    function addToWhitelist(address[] addresses, uint[] amounts)
        public onlyOwner
    {
        require(addresses.length != 0 && addresses.length == amounts.length);
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != 0x0);
            whitelist[addresses[i]] = amounts[i];
            Whitelisted(addresses[i], amounts[i]);
        }
    }
    event Whitelisted(address indexed whitelistedAddress, uint amount);


    // ------------------------------------------------------------------------
    // Add precommitment funding token balance and ether cost before the
    // crowdsale commences
    // ------------------------------------------------------------------------
    function addPrecommitment(address participant, uint tokens, uint ethers) public onlyOwner {
        // Can only add precommitments before the crowdsale starts
        require(block.timestamp < START_DATE);

        // Check tokens > 0
        require(tokens > 0);

        // Mint tokens
        mint(participant, tokens);

        // Keep track of ethers raised
        ethersRaised = ethersRaised.add(ethers);

        // Log event
        PrecommitmentAdded(participant, tokens, ethers);
    }
    event PrecommitmentAdded(address indexed participant, uint tokens, uint ethers);


    // ------------------------------------------------------------------------
    // Fallback function to receive ETH contributions send directly to the
    // contract address
    // ------------------------------------------------------------------------
    function() public payable {
        proxyPayment(msg.sender);
    }


    // ------------------------------------------------------------------------
    // Receive ETH contributions. Can use this to send tokens to another
    // account
    // ------------------------------------------------------------------------
    function proxyPayment(address contributor) public payable {
        // Check we are still in the crowdsale period
        require(block.timestamp >= START_DATE && block.timestamp <= END_DATE);

        // Check for invalid address
        require(contributor != 0x0);

        // Check that contributor has sent ETH
        require(msg.value > 0);

        // Keep track of ETH raised
        ethersRaised = ethersRaised.add(msg.value);

        // Check we have not exceeded the hard cap
        require(ethersRaised <= ETH_HARD_CAP);

        // Calculate tokens for contributed ETH
        uint tokens = msg.value.mul(tokensPerKEther).div(1000);

        // Mint tokens for contributor
        mint(contributor, tokens);

        // Log ETH contributed and tokens generated
        TokensBought(contributor, msg.value, tokens);

        // Transfer ETH crowdsale wallet 
        WALLET_CROWDSALE.transfer(msg.value);
    }
    event TokensBought(address indexed contributor, uint ethers, uint tokens);


    // ------------------------------------------------------------------------
    // Finalise crowdsale, mint reserve tokens
    // ------------------------------------------------------------------------
    function finalise() public onlyOwner {
        // Can only finalise once
        require(!finalised);

        // Can only finalise if we are past end date, or hard cap reached
        require(block.timestamp > END_DATE || ethersRaised == ETH_HARD_CAP);

        // Mint reserve tokens
        uint divFactor = 100-PERCENT_RESERVE;
        uint advisorTokens = totalSupply.mul(PERCENT_ADVISORS).div(divFactor);
        uint teamTokens = totalSupply.mul(PERCENT_TEAM).div(divFactor);
        uint contractorsTokens = totalSupply.mul(PERCENT_CONTRACTORS).div(divFactor);
        uint growthPoolTokens = totalSupply.mul(PERCENT_GROWTH_POOL).div(divFactor);
        mint(WALLET_ADVISORS, advisorTokens);
        mint(WALLET_TEAM, teamTokens);
        mint(WALLET_CONTRACTORS, contractorsTokens);
        mint(WALLET_GROWTH_POOL, growthPoolTokens);

        // Mark as finalised 
        finalised = true;

        // Allow tokens to be transferable
        transferable = true;
    }


    // ------------------------------------------------------------------------
    // transfer tokens, only transferable after the crowdsale is finalised
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public isTransferable 
        returns (bool success) 
    {
        return super.transfer(to, tokens);
    }


    // ------------------------------------------------------------------------
    // transferFrom tokens, only transferable after the crowdsale is finalised
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public
        isTransferable returns (bool success)
    {
        return super.transferFrom(from, to, tokens);
    }
}