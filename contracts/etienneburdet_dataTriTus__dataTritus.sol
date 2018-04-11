//For assigning ownership and transfering it and basic modifier
contract owned {
  address public owner;

  function owned() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    if (msg.sender != owner) throw;
    _
  }

  function transferOwnership(address newOwner) onlyOwner {
    owner = newOwner;
  }
}

// Function to recover the funds on the contract
contract mortal is owned {
  function kill() onlyOwner{
    selfdestruct(owner);
  }
}



//Contract with function to administrate a station. Can generate wastetypes, addbins and scan bins.
contract mySation is owned, mortal{

  mapping(uint => tokenDechet) public wasteTypes;   //Address list of created tokens (for use in Mist mainly)
  uint numWt; //wasteTypes id
  mapping(address => uint) public contractorType; //Tells if it's pick up (substract waste) or cleaning (add waste) company. No boolean because we can add other kind of companies later.
  mapping(uint => tokenDechet) public binTypes; //map bins id to conrepsonding token to retrieve which type of waste it contains.


  //Add a new type of waste (effectively creates a new token)
  function addWasteType(string wasteName) onlyOwner returns(address addr) {
    owner = this;
    wasteTypes[numWt] = new tokenDechet(wasteName, owner, "kg", 0, 0); //Owner of token is the main account ownings the myStation contract. Maybe it should be 'this' ?
    numWt++;
    return wasteTypes[numWt];
  }


  //Add a contractor. For now can be pick up (removes waste) or cleaning (adds waste). Further types later.
  function addContractor(address _addr, uint _type) returns(bool res) {
    if(_addr !=0x0){
      contractorType[_addr] = _type;
      return true;
    } else {
      return false;
    }
  }

  function addBin(tokenDechet _tokenAddr, uint _id) returns(bool res) {
    binTypes[_id] = _tokenAddr; //Link the new id to the token address to define type of waste.
    return true;
  }


  //Bin is scanned. Depending who scans, it's either taken out (+waste for the station) or picked up (+waste for the contractor, -waste for the station)
  function binScan(uint _binid, address _scannerAddr) returns(bool res) {
    uint256 weight = 60;
    tokenDechet wT = binTypes[_binid];//Retrieve the waste type to transfer/mint depending on the bin id
    if ( contractorType[_scannerAddr] == 1) {
      wT.mintToken(this.owner, weight);
      return true;
    }
    else if ( contractorType[_scannerAddr] == 2) {
      wT.transferFrom(this.owner, _scannerAddr,weight);
      return true;
    }
    else {
      return false;
    }
  }


}


/*This part is based on the official Ethereum token tutorail */
contract tokenDechet is owned, mortal {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Initializes contract with initial supply tokens to the creator of the contract
    function tokenDechet(
        string tokenName,
        address Minter,
        string tokenSymbol,
        uint256 initialSupply,
        uint8 decimalUnits                                    //Adress of the guy who can add tokens
        ) {
        if (Minter != 0 ) owner = Minter;
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
}


    //Create kg when needed. Only the one who created the waste type can do that.
    function mintToken(address target, uint256 mintedAmount) onlyOwner {
      balanceOf[target] += mintedAmount;
      totalSupply += mintedAmount;
      Transfer(0, owner, mintedAmount);
      Transfer(owner, target, mintedAmount);
    }

    // Send kg from caller address
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }


    // Transfer kg between two contracts if caller owns the contract _from
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(_from, _to, _value);
        return true;
    }

}
