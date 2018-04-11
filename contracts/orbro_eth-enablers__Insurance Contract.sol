contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

    contract MyToken {
        /* Public variables of the token */
        string public standard = 'Token 0.1';
        string public name;
        string public identifier;
        uint256 public claim;
        uint8 public decimals;
        uint256 public totalSupply;
        string public contractType;
        string public coveredRisk;
        string public deductible;
        string public contractCurrency;
        string public jurisdiction;
        string public premium;
        string public premiumType;

        /* This creates an array with all balances */
        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowance;

        /* This generates a public event on the blockchain that will notify clients */
        event Transfer(address indexed from, address indexed to, uint256 value);

        /* Initializes contract with initial supply tokens to the creator of the contract */
        function MyToken(
            uint256 initialSupply,
            string tokenName,
            uint8 decimalUnits,
            string tokenIdentifier,
            uint256 claimValue,
            uint8 decimals,
            uint256 totalSupply,
            string contractType,
            string coveredRisk,
            string deductible,
            string contractCurrency,
            string jurisdiction,
            string premium,
            string premiumType
            ) {
            balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
            totalSupply = initialSupply;                        // Update total supply
            name = tokenName;                                   // Set the name for display purposes
            identifier = tokenIdentifier;                       // Set the unique identifier of the contract
            decimals = decimalUnits;                            // Amount of decimals for display purposes
            claim = claimValue;									// Amount of the claim of the insurance contract
            decimals = decimals;
            totalSupply = totalSupply;
            contractType = contractType;                        //All variables from this point forward are insurance-related
            coveredRisk = coveredRisk;
            deductible = deductible;
            contractCurrency = contractCurrency;
            jurisdiction = jurisdiction;
            premium = premium;
            premiumType = premiumType;
        }

        /* Send coins */
        function transfer(address _to, uint256 _value) {
            if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
            if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
            balanceOf[msg.sender] -= _value;                     // Subtract from the sender
            balanceOf[_to] += _value;                            // Add the same to the recipient
            Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        }

            /* Allow another contract to spend some tokens in your behalf */
            function approveAndCall(address _spender, uint256 _value, bytes _extraData)
                returns (bool success) {
                allowance[msg.sender][_spender] = _value;
                tokenRecipient spender = tokenRecipient(_spender);
                spender.receiveApproval(msg.sender, _value, this, _extraData);
                return true; 
            }

            /* A contract attempts to get the coins */
            function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
                if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
                if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
                if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
                balanceOf[_from] -= _value;                          // Subtract from the sender
                balanceOf[_to] += _value;                            // Add the same to the recipient
                allowance[_from][msg.sender] -= _value;
                Transfer(_from, _to, _value);
                return true;
            }

            /* This unnamed function is called whenever someone tries to send ether to it */
            function () {
                throw;     // Prevents accidental sending of ether
            }
        }