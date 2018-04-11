import "Owned.sol";

contract ReviewToken is Owned {
    /* public variables of the token */
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public sellprice;
    uint256 public buyprice;
    uint256 public totalsupply;

    /* this creates an array with all balances */
    mapping (address => uint256) public balanceof;
    mapping (address => bool) public frozenaccount;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => mapping (address => uint256)) public spentallowance;

    /* this generates a public event on the blockchain that will notify clients */
    event transfer(address indexed from, address indexed to, uint256 value);
    event frozenfunds(address target, bool frozen);

    /* initializes contract with initial supply tokens to the creator of the contract */
    function ReviewToken(
        uint256 initialsupply,
        string tokenname,
        uint8 decimalunits,
        string tokensymbol,
        address centralminter
    ) {
        if(centralminter != 0 ) owner = msg.sender;         // sets the minter
        balanceof[msg.sender] = initialsupply;              // give the creator all initial tokens
        name = tokenname;                                   // set the name for display purposes
        symbol = tokensymbol;                               // set the symbol for display purposes
        decimals = decimalunits;                            // amount of decimals for display purposes
        totalsupply = initialsupply;
    }

    /* send coins */
    function transferold(address _to, uint256 _value) {
        if (balanceof[msg.sender] < _value) throw;           // check if the sender has enough
        if (balanceof[_to] + _value < balanceof[_to]) throw; // check for overflows
        if (frozenaccount[msg.sender]) throw;                // check if frozen
        balanceof[msg.sender] -= _value;                     // subtract from the sender
        balanceof[_to] += _value;                            // add the same to the recipient
        transfer(msg.sender, _to, _value);                   // notify anyone listening that this transfer took place
    }

    /* allow another contract to spend some tokens in your behalf */
    function approveandcall(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        tokenrecipient spender = tokenrecipient(_spender);
        spender.receiveapproval(msg.sender, _value, this);
        return true;
    }

    /* a contract attempts to get the coins */
    function transferfrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceof[_from] < _value) throw;                 // check if the sender has enough
        if (balanceof[_to] + _value < balanceof[_to]) throw;  // check for overflows
        if (spentallowance[_from][msg.sender] + _value > allowance[_from][msg.sender]) throw;   // check allowance
        balanceof[_from] -= _value;                          // subtract from the sender
        balanceof[_to] += _value;                            // add the same to the recipient
        spentallowance[_from][msg.sender] += _value;
        transfer(_from, _to, _value);
        return true;
    }

    /* this unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // prevents accidental sending of ether
    }

    function minttoken(address target, uint256 mintedamount) onlyOwner {
        balanceof[target] += mintedamount;
        totalsupply += mintedamount;
        transfer(0, owner, mintedamount);
        transfer(owner, target, mintedamount);
    }

    function freezeaccount(address target, bool freeze) onlyOwner {
        frozenaccount[target] = freeze;
        frozenfunds(target, freeze);
    }

    function setprices(uint256 newsellprice, uint256 newbuyprice) onlyOwner {
        sellprice = newsellprice;
        buyprice = newbuyprice;
    }

    function buy() {
        uint amount = msg.value / buyprice;                // calculates the amount
        if (balanceof[this] < amount) throw;               // checks if it has enough to sell
        balanceof[msg.sender] += amount;                   // adds the amount to buyer's balance
        balanceof[this] -= amount;                         // subtracts amount from seller's balance
        transfer(this, msg.sender, amount);                // execute an event reflecting the change
    }

    function sell(uint256 amount) {
        if (balanceof[msg.sender] < amount ) throw;        // checks if the sender has enough to sell
        balanceof[this] += amount;                         // adds the amount to owner's balance
        balanceof[msg.sender] -= amount;                   // subtracts the amount from seller's balance
        if (!msg.sender.send(amount * sellprice)) throw;   // sends ether to the seller
        transfer(msg.sender, this, amount);                // executes an event reflecting on the change
    }
}

contract tokenrecipient {
    function receiveapproval(address _from, uint256 _value, address _token);
}
