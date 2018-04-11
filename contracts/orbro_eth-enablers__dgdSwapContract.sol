// Version 0.21
// This swap contract was created by Attores and released under a GPL license. 
// Please note that this contract is still in beta. Hence use only the amounts that you can afford to lose in case of an unforeseen bug.
// Visit attores.com for more contracts and Smart contract as a Service 

// This is the standard token interface
contract TokenInterface {

  struct User {
    bool locked;
    uint256 balance;
    uint256 badges;
    mapping (address => uint256) allowed;
  }

  mapping (address => User) users;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => bool) seller;

  address config;
  address owner;
  address dao;
  bool locked;

  /// @return total amount of tokens
  uint256 public totalSupply;
  uint256 public totalBadges;

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) constant returns (uint256 balance);

  /// @param _owner The address from which the badge count will be retrieved
  /// @return The badges count
  function badgesOf(address _owner) constant returns (uint256 badge);

  /// @notice send `_value` tokens to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of tokens to be transfered
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) returns (bool success);

  /// @notice send `_value` badges to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of tokens to be transfered
  /// @return Whether the transfer was successful or not
  function sendBadge(address _to, uint256 _value) returns (bool success);

  /// @notice send `_value` tokens to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of tokens to be transfered
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

  /// @notice `msg.sender` approves `_spender` to spend `_value` tokens on its behalf
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of tokens to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens of _owner that _spender is allowed to spend
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);

  /// @notice mint `_amount` of tokens to `_owner`
  /// @param _owner The address of the account receiving the tokens
  /// @param _amount The amount of tokens to mint
  /// @return Whether or not minting was successful
  function mint(address _owner, uint256 _amount) returns (bool success);
  function calculateTxFee(uint256 _value, address _user) public returns (uint256);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event SendBadge(address indexed _from, address indexed _to, uint256 _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract swap{
    address public beneficiary;
    TokenInterface public tokenObj;
    uint public price_token;
    uint256 public WEI_PER_FINNEY = 1000000000000000;
    uint public BILLION = 1000000000;
    uint public expiryDate;
    uint public balance;
    
    // Constructor function for this contract. Called during contract creation
    function swap(address sendEtherTo, address adddressOfToken, uint tokenPriceInFinney_1000FinneyIs_1Ether, uint durationInDays){
        beneficiary = sendEtherTo;
        tokenObj = TokenInterface(adddressOfToken);
        price_token = tokenPriceInFinney_1000FinneyIs_1Ether * WEI_PER_FINNEY;
        expiryDate = now + durationInDays * 1 days;
    }
    
    function(){
        if (now >= expiryDate) throw;
        // Dividing by Billion here to cater for the decimal places
        var tokens_to_send = (msg.value * BILLION) / price_token;
        balance = tokenObj.allowance(beneficiary, this);
        address payee = msg.sender;
        if (balance >= tokens_to_send){
            tokenObj.transferFrom(beneficiary, msg.sender, tokens_to_send);
            beneficiary.send(msg.value);    
        } else {
            tokenObj.transferFrom(beneficiary, msg.sender, balance);
            uint amountReturned = ((tokens_to_send - balance) * price_token) / BILLION;
            payee.send(amountReturned);
            beneficiary.send(msg.value - amountReturned);
        }
    }
    
    modifier afterExpiry() { if (now >= expiryDate) _ }
    
    modifier ifBeneficiary() { 
        if (beneficiary != msg.sender) {
            throw;
        } else {
            _
        }
    }
    
    // To kill the swap after expiry date
    function killSwap() ifBeneficiary afterExpiry{
        suicide(beneficiary);
    }
  
    // This function is a fail-safe in case someone "sends" the tokens to this contract instead of "approving" them
    function emergencyWithdrawal(address token) ifBeneficiary{
        uint balance = TokenInterface(token).balanceOf(this);
        // In case of DGX, there is a 0.13% TXN fee, hence we need to do this
        if (token == 0x55b9a11c2e8351b4ffc7b11561148bfac9977855){
            uint txnFee = TokenInterface(token).calculateTxFee(balance, this);
            uint amountReturned = balance - txnFee;
            TokenInterface(token).transfer(beneficiary, amountReturned);
        } else {
            TokenInterface(token).transfer(beneficiary, balance);
        }
    }
}