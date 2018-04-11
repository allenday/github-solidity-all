contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract MyToken {
    /* Public variables of the token */
    string public name;
    string public symbol;
    string public version;
    uint8  public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* An array of owners is required to iterate over owners */
    address[] public owners;

    /* Address could be deleted from owners array if owned token are 0 */
    function del(uint _idx)  {
      var addr=owners[_idx];
      if(balanceOf[addr]>0) throw;
      owners[_idx]=owners[owners.length-1];
      owners.length=owners.length-1;
    }

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(
        string tokenName,
        string tokenSymbol
        ) {
        totalSupply = 200;                                // Update total supply
        balanceOf[msg.sender] = totalSupply;              // Give the creator all initial tokens
        owners[owners.length++] = msg.sender;
        name = tokenName;                                 // Set the name for display purposes
        symbol = tokenSymbol;                             // Set the symbol for display purposes
        decimals = 0;                                     // Amount of decimals for display purposes
    }

    function totalOwners() constant returns(uint) {
      return owners.length;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        var exist = balanceOf[_to] > 0;                      // Check if recipient already exist in list
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        if(!exist)
          owners[owners.length++]=_to;                       // Add to the array of owners if there wasn't
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }


    function () {
      throw;
    }
}
