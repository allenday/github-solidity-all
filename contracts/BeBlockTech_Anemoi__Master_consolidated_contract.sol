pragma solidity ^0.4.11;

// ================= Ownable Contract start =============================
/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}
// ================= Ownable Contract end ===============================

// ================= Safemath Contract start ============================
/* taking ideas from FirstBlood token */
contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }
}
// ================= Safemath Contract end ==============================

// ================= ERC20 Token Contract start =========================
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}
// ================= ERC20 Token Contract end ===========================

// ================= Standard Token Contract start ======================
contract StandardToken is ERC20, SafeMath {

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4) ;
     _;
  }

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32)  returns (bool success){
    balances[msg.sender] = safeSubtract(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSubtract(balances[_from], _value);
    allowed[_from][msg.sender] = safeSubtract(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}
// ================= Standard Token Contract end ========================

// ================= Pausable Token Contract start ======================
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require (paused) ;
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}
// ================= Pausable Token Contract end ========================

// ================= Indorse Token Contract start =======================
contract AnemoiToken is SafeMath, StandardToken, Pausable {
    // metadata
    string public constant name = "Anemoi Token";
    string public constant symbol = "ANM";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public anmSaleDeposit        = "###";      // deposit address for Anemoi Sale contract
    address public anmSeedDeposit        = "###";      // deposit address for Anemoi Seed Contributors
    address public anmPresaleDeposit     = "###";      // deposit address for Anemoi Presale Contributors
    address public anmVestingDeposit     = "###";      // deposit address for Anemoi Vesting for team and advisors
    address public anmCommunityDeposit   = "###";      // deposit address for Anemoi Marketing, etc
    address public anmFutureDeposit      = "###";      // deposit address for Anemoi Future token sale
    address public anmInflationDeposit   = "###";      // deposit address for Anemoi Inflation pool
    
    uint256 public constant anmSale      = 31603785 * 10**decimals;                         
    uint256 public constant anmSeed      = 3566341  * 10**decimals; 
    uint256 public constant anmPreSale   = 22995270 * 10**decimals;                       
    uint256 public constant anmVesting   = 28079514 * 10**decimals;  
    uint256 public constant anmCommunity = 10919811 * 10**decimals;  
    uint256 public constant anmFuture    = 58832579 * 10**decimals;  
    uint256 public constant anmInflation = 14624747 * 10**decimals;  
   
    // constructor
    function IndorseToken()
    {
      balances[indSaleDeposit]           = indSale;                                         // Deposit ANM share
      balances[indSeedDeposit]           = indSeed;                                         // Deposit ANM share
      balances[indPresaleDeposit]        = indPreSale;                                      // Deposit ANM future share
      balances[indVestingDeposit]        = indVesting;                                      // Deposit ANM future share
      balances[indCommunityDeposit]      = indCommunity;                                    // Deposit ANM future share
      balances[indFutureDeposit]         = indFuture;                                       // Deposit ANM future share
      balances[indInflationDeposit]      = indInflation;                                    // Deposit for inflation

      totalSupply = indSale + indSeed + indPreSale + indVesting + indCommunity + indFuture + indInflation;

      Transfer(0x0,indSaleDeposit,indSale);
      Transfer(0x0,indSeedDeposit,indSeed);
      Transfer(0x0,indPresaleDeposit,indPreSale);
      Transfer(0x0,indVestingDeposit,indVesting);
      Transfer(0x0,indCommunityDeposit,indCommunity);
      Transfer(0x0,indFutureDeposit,indFuture);
      Transfer(0x0,indInflationDeposit,indInflation);
   }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
  }
}
// ================= Indorse Token Contract end =======================

// ================= Actual Sale Contract Start ====================
contract IndorseSaleContract is  Ownable,SafeMath,Pausable {
    IndorseToken    ind;

    // crowdsale parameters
    uint256 public fundingStartTime = 1502193600;
    uint256 public fundingEndTime   = 1504785600;
    uint256 public totalSupply;
    address public ethFundDeposit   = "###";      // deposit address for ETH for Anemoi Fund
    address public anmFundDeposit   = "###";      // deposit address for Anemoi reserve
    address public anmAddress       = "###";

    bool public isFinalized;                                                            // switched to true in operational state
    uint256 public constant decimals = 18;                                              // #dp in Indorse contract
    uint256 public tokenCreationCap;
    uint256 public constant tokenExchangeRate = 1000;                                   // 1000 ANM tokens per 1 ETH
    uint256 public constant minContribution = 0.05 ether;
    uint256 public constant maxTokens = 1 * (10 ** 6) * 10**decimals;
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;                            // maximum gas price for contribution transactions
 
    function AnemoiSaleContract() {
        anm = AnemoiToken(anmAddress);
        tokenCreationCap = anm.balanceOf(anmFundDeposit);
        isFinalized = false;
    }

    event MintANM(address from, address to, uint256 val);
    event LogRefund(address indexed _to, uint256 _value);

    function CreateANM(address to, uint256 val) internal returns (bool success){
        MintANM(anmFundDeposit,to,val);
        return anm.transferFrom(anmFundDeposit,to,val);
    }

    function () payable {    
        createTokens(msg.sender,msg.value);
    }

    /// @dev Accepts ether and creates new ANM tokens.
    function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
      require (tokenCreationCap > totalSupply);                                         // CAP reached no more please
      require (now >= fundingStartTime);
      require (now <= fundingEndTime);
      require (_value >= minContribution);                                              // To avoid spam transactions on the network    
      require (!isFinalized);
      require (tx.gasprice <= MAX_GAS_PRICE);

      uint256 tokens = safeMult(_value, tokenExchangeRate);                             // check that we're not over totals
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      require (anm.balanceOf(msg.sender) + tokens <= maxTokens);
      
      // DA ... to fairly allocate the last few tokens
      if (tokenCreationCap < checkedSupply) {        
        uint256 tokensToAllocate = safeSubtract(tokenCreationCap,totalSupply);
        uint256 tokensToRefund   = safeSubtract(tokens,tokensToAllocate);
        totalSupply = tokenCreationCap;
        uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

        require(CreateANM(_beneficiary,tokensToAllocate));                              // Create ANM
        msg.sender.transfer(etherToRefund);
        LogRefund(msg.sender,etherToRefund);
        ethFundDeposit.transfer(this.balance);
        return;
      }
      // DA ... end of fair allocation code

      totalSupply = checkedSupply;
      require(CreateANM(_beneficiary, tokens));                                         // logs token creation
      ethFundDeposit.transfer(this.balance);
    }
    
    /// @dev Ends the funding period and sends the ETH home
    function finalize() external onlyOwner {
      require (!isFinalized);
      // move to operational
      isFinalized = true;
      ethFundDeposit.transfer(this.balance);                                            // send the eth to Anemoi multi-sig
    }
}