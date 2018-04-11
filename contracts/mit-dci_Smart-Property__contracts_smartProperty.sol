
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract smartProperty {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint public supplyIncreaseRate;
    address public CEOaddress;
    uint256 public paidUntil;
    address public currentHolder;
    uint256 public price;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(uint => address) public indexes;
    uint public currentIndex;
    mapping (address => uint) etherBalanceOf;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Payment(address payer, uint256 paidUntil);
    /* Initializes contract with initial supply tokens to the creator of the contract */
    function smartProperty(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        address ceoAddress,
        uint256 supplyIncRateNum,
        uint256 supplyIncRateDen,
        uint256 _price
        ) {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        CEOaddress = ceoAddress;                            // Set the address of the Ceo.
        supplyIncreaseRate = supplyIncRateNum/supplyIncRateDen;                    // Equity goal to distribute a token to CEO
        msg.sender.send(msg.value);                         // Sends back any money sent on creation
        currentIndex = 0;
        price = _price;                                      // Price for service in Wei/min
        indexes[currentIndex] = msg.sender;
        if(ceoAddress != msg.sender){
          currentIndex = 1;
          indexes[currentIndex] = ceoAddress;
        }
        paidUntil = now;


        }

    /* Transfer shares */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        //Don't want indexes to map to addresses that already exist.
        if(balanceOf[_to] == 0){
            currentIndex ++;
            indexes[currentIndex] = _to;
        }
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to transfer shares on your behalf */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        tokenRecipient spender = tokenRecipient(_spender);
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    /* A contract attempts to transfer shares */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        //Don't want indexes to map to addresses that already exist.
        if(balanceOf[_to] == 0){
            currentIndex ++;
            indexes[currentIndex] = _to;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    // withdraw funds
   function withDraw(){
        if(etherBalanceOf[msg.sender]>0){
            uint value = etherBalanceOf[msg.sender];
            etherBalanceOf[msg.sender] = 0;
            msg.sender.send(value);

        }
    }

    // Credits CEO with additional shares and increases total shares
    // thereby diluting external shareholders
    function dilute(uint256 shares) private {
        balanceOf[CEOaddress] += shares;
        totalSupply += shares;
    }

    // Credits shareholder accounts with dividend payments
    function creditDividends(uint256 value) private {
        for(var i = 0; i < currentIndex + 1; i++){
            etherBalanceOf[indexes[i]] += balanceOf[indexes[i]]/totalSupply*value;
        }
    }


    function pay(){
        // Payment is only accepted if the property is not currently rented
        if (now >= paidUntil){

            // Credit shareholder accounts with dividend payment
            creditDividends(msg.value);

            // Increase shares of CEO and total share -> Dilution of external shareholders
            dilute(msg.value/1000000000000000000 * supplyIncreaseRate);

            currentHolder = msg.sender;
            paidUntil = now + msg.value/price * 1 minutes;
            Payment(msg.sender, paidUntil);
        }
        else{
            throw;
        }
    }
    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;
    }
}
