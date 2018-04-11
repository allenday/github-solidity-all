pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

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
}

contract ERC23ContractInterface {
  function tokenFallback(address _from, uint256 _value, bytes _data) external;
}

contract ERC23Contract is ERC23ContractInterface {

 /**
  * @dev Reject all ERC23 compatible tokens
  * param _from address that is transferring the tokens
  * param _value amount of specified token
  * param _data bytes data passed from the caller
  */
  function tokenFallback(address /*_from*/, uint256 /*_value*/, bytes /*_data*/) external {
    revert();
  }

}

contract ERC677ContractInterface {
  function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool);
  function receiveTransfer(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool);
  event ReceiveApproval(address indexed from, uint256 value, address indexed tokenContract, bytes indexed data);
  event ReceiveTransfer(address indexed from, uint256 value, address indexed tokenContract, bytes indexed data);
}

contract ERC677Contract is ERC677ContractInterface {

  /* Processes token approvals */
  function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool) {
    ReceiveApproval(_from, _value, _tokenContract, _data);
    return true;
  }

  /* Processes token transfers */
  function receiveTransfer(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool) {
    ReceiveTransfer(_from, _value, _tokenContract, _data);
    return true;
  }

}

library Lib {
  // whether given address is a contract or not based on bytecode
  function isContract(address addr) internal constant returns (bool) {
    uint size;
    assembly {
      size := extcodesize(addr)
    }
    return (size > 1); // testing returned size "1" for non-contract accounts, so we're using that.
  }
}

contract Benable is Ownable {
  address public ben; // beneficiary

  event BenshipTransferred(address indexed prevAddr, address indexed newAddr);

  /**
   * @dev The Benable constructor sets the original `ben` of the contract to the sender
   * account.
   */
  function Benable() {
    ben = msg.sender;
  }


  /**
   * @dev Modifier throws if called by any account other than the ben.
   */
  modifier onlyBen() {
    require(msg.sender == ben);
    _;
  }


  /**
   * @dev Allows the current ben to set the ben address.
   * @param newAddr The address to transfer benship to.
   */
  function transferBenship(address newAddr) onlyBen public {
    require(newAddr != address(0));
    BenshipTransferred(ben, newAddr);
    ben = newAddr;
  }

}

contract Devable is Ownable {
  address public dev; // developer

  event DevshipTransferred(address indexed prevAddr, address indexed newAddr);

  /**
   * @dev The Devable constructor sets the original `dev` of the contract to the sender
   * account.
   */
  function Devable() {
    dev = msg.sender;
  }


  /**
   * @dev Modifier throws if called by any account other than the dev.
   */
  modifier onlyDev() {
    require(msg.sender == dev);
    _;
  }


  /**
   * @dev Allows the current dev to set the dev address.
   * @param newAddr The address to transfer devship to.
   */
  function transferDevship(address newAddr) onlyDev public {
    require(newAddr != address(0));
    DevshipTransferred(dev, newAddr);
    dev = newAddr;
  }

}

contract DonorCrowdsale is Crowdsale, CappedCrowdsale, Benable, Devable, ERC23Contract, ERC677Contract {
  using SafeMath for uint256;

  uint256 public constant UINT256_MAX = 2**256 - 1;

  // feel free to overridde!
  uint256 public constant CAP_DEFAULT = 100000 ether; // Crowdsale will end when this much ether is received
  uint256 public constant TOKEN_RATE = 1 wei; // NOTE: instead of mul, we use div; i.e. this is ether cost per token, aka minimum payment
  uint256 public constant DONEE_PCT = 95; // donee gets this, dev fund gets remainder
  uint256 public constant DONEE_TOKEN_THRESHOLD = 1 ether; // every time we reach this threshold raised, also mint 1 token to donee, dev
  uint256 public constant DONEE_SEND_THRESHOLD = 1 ether; // "payout" ether to donee each time we have this much
  uint256 public constant EARLYBIRD_PERIOD = 4 weeks; // anyone who buys in this period receives a bonus
  uint256 public constant BONUS_THRESHOLD = 1 ether; // for each of these donated, give bonus
  uint256 public constant BONUS_TOKEN_RATE = 100 finney; // bonus rate awarded (proportional to rate!)
  bool public constant REFUND_FAIL_THROW = false; // if refund attempt fails, throw?

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   * @param refund weis refunded
   */ 
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint256 refund);


  function DonorCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _cap)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap) 
  {
    ben = _wallet;
    transferOwnership(this); // give the contract to itself
  }

  // override this method to have crowdsale of a specific DonorToken.
  function createTokenContract() internal returns (MintableToken) {
    return new DonorToken();
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.div(rate); // NOTE: using div instead of mul!
    require(tokens > 0); // if payment wasn't enough for 1 token, throw

    uint256 weiAccept = tokens.mul(rate);
    uint256 weiRefund = weiAmount.sub(weiAccept);

    // special processing
    uint256 tokensBonus = buyTokensBonus(tokens, weiAccept);
    tokens = tokens.add(tokensBonus);

    // update state
    weiRaised = weiRaised.add(weiAccept);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAccept, tokens, weiRefund);

    if (weiRefund > 0) {
      if (REFUND_FAIL_THROW) {
        // throws on fail
        msg.sender.transfer(weiRefund);
      } else {
        // does not throw (dust kept for donation)
        if (!msg.sender.send(weiRefund)) {
          return; // out of gas, apparently
        }
      }
    }

    forwardFunds();
  }

  // any "non-critical" special processing (bonus tokens, etc) at buy time
  // override to create custom bonus mechanisms (can also just return 0)
  function buyTokensBonus(uint256 tokens, uint256 weiAccept) internal returns (uint256) {
    uint256 tokensBonus = 0;

    checkThreshold(weiAccept);
    tokensBonus = tokensBonus.add(checkEarlybird(tokens));
    tokensBonus = tokensBonus.add(checkWhale(weiAccept));

    return tokensBonus;
  }

  // also mint 1 token to donee, dev per threshold diff (ex: per ether received)
  function checkThreshold(uint256 weiAccept) internal returns (bool) {
    uint256 weiRaisedPrev = weiRaised;
    uint256 weiRaisedNext = weiRaisedPrev.add(weiAccept);
    uint256 weiThreshPrev = weiRaisedPrev.div(DONEE_TOKEN_THRESHOLD);
    uint256 weiThreshNext = weiRaisedNext.div(DONEE_TOKEN_THRESHOLD);
    uint256 weiThreshDiff = weiThreshNext.sub(weiThreshPrev);
    if (weiThreshDiff > 0) {
      token.mint(wallet, weiThreshDiff);
      token.mint(dev, weiThreshDiff);
      return true;
    }

    return false;
  }

  // bonus X% where X is days left in earlybird period
  function checkEarlybird(uint256 tokens) internal constant returns (uint256) {
    uint256 startTimeSince = now.sub(startTime);
    if (startTimeSince < EARLYBIRD_PERIOD) {
      uint256 daysRem = EARLYBIRD_PERIOD.sub(startTimeSince).div(1 days);
      return tokens.mul(daysRem).div(100);
    }

    return 0;
  }

  // bonus X finney's worth for every ether donated
  function checkWhale(uint256 weiAccept) internal constant returns (uint256) {
    return weiAccept.div(BONUS_THRESHOLD).mul(BONUS_TOKEN_RATE).div(rate);
  }

  // send proceeds to the donee wallet, and any leftovers to dev
  function forwardFunds() internal {
    uint256 bal = this.balance;
    // require(bal > 0); // don't need this due to DONEE_SEND_THRESHOLD check below

    if (bal < DONEE_SEND_THRESHOLD) {
      return; // wait until we have enough to send
    }

    uint256 proceeds = bal.mul(DONEE_PCT).div(100);
    if (!wallet.send(proceeds)) {
      return; // transfer() would throw if out of gas, and we lose the donation; just wait for next one
    }

    uint256 leftover = bal.sub(proceeds);
    if (leftover > 0) {
      if (!dev.send(leftover)) {
        return; // don't throw here either
      }
    }
  }

  // Overrides base ERC23Contract to accept ERC23 compatible tokens
  function tokenFallback(address /*_from*/, uint256 /*_value*/, bytes /*_data*/) external {
    // may have received transfer from ERC23Token.transfer, which calls tokenFallback, so check
    tokenSweep(0x0, msg.sender);
  }

  // Overrides base ERC677Contract
  function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool) {
    tokenSweep(_from, _tokenContract);

    ReceiveApproval(_from, _value, _tokenContract, _data);
    return true;
  }

  // Overrides base ERC677Contract
  function receiveTransfer(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool) {
    // may have already swept in ERC23Token.transfer tokenFallback call, so check
    tokenSweep(0x0, _tokenContract);

    ReceiveTransfer(_from, _value, _tokenContract, _data);
    return true;
  }

  // let dev sweep ERC20 tokens (i.e. not ether) which were sent w/o receiveApproval/receiveTransfer
  // don't pass potential token spam to ben, but devs don't mind, so throw them a bone :)
  // permissionless b/c receiver (dev) is hardcoded; can be called internally or externally
  // NOTE: be sure to use _from=0x0 to transfer tokens already in this possession
  function tokenSweep(address _from, address _tokenContract) public {
    StandardToken tok = StandardToken(_tokenContract);
    if(_from == address(0)) {
      uint256 tokBal = tok.balanceOf(this); // check actual balance instead of _value
      if (tokBal > 0) {
        tok.transfer(dev, tokBal);
      }
    } else {
      uint256 tokAllow = tok.allowance(_from, this); // check actual allowance instead of _value
      if (tokAllow > 0) {
        tok.transferFrom(_from, dev, tokAllow);
      }
    }
  }

  /**
   * @dev Allows the current ben to change the ben AND wallet address (overrides & calls Benable).
   * @param newAddr The address to transfer benship to.
   */
  function transferBenship(address newAddr) onlyBen public {
    transferWallet(newAddr);
    super.transferBenship(newAddr); // must be called last (subsequent onlyBen funcs would fail!)
  }

  /**
   * @dev Allows the current ben to change the wallet address only.
   * @param newAddr The address to transfer wallet to.
   */
  function transferWallet(address newAddr) onlyBen public {
    wallet = newAddr;
  }

  /**
   * @dev Allows the dev to one-time launch, iff deployed with startTime == endTime.
   * NOTE: be sure to set after next block will be mined!
   * @param _startTime the new start timestamp
   */
  function onetimeLaunch(uint256 _startTime) external onlyDev {
    require(startTime == endTime);
    require(_startTime >= now);
    require(_startTime < endTime);

    startTime = _startTime;
  }

}

contract MDTCrowdsale is DonorCrowdsale {

  uint256 public constant TOKEN_RATE = 1 szabo; // ether cost per token, aka minimum payment
  address public constant INITIAL_WALLET = 0x2F6dA3986a36f8dBd559b94CF9D6857779b429E2; // that's us!

  function MDTCrowdsale(address _tokenAddr)
    DonorCrowdsale(now, UINT256_MAX, TOKEN_RATE, INITIAL_WALLET, CAP_DEFAULT)
  {
    // instead of Crowdsale creating token, we create it beforehand to decouple & split gas costs
  	token = MDToken(_tokenAddr);
    // remember to also token.transferOwnership to this contract after deploying
  }

  function createTokenContract() internal returns (MintableToken) {
    return token; // don't actually create new token since we're assigning in constructor
  }

}

contract ERC23Token is BasicToken, ERC23Contract {

  event Transfer(address indexed from, address indexed to, uint256 value, bytes /*indexed*/ data);

  function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {
    super.transfer(_to, _value);

    if (Lib.isContract(_to)) {
      ERC23ContractInterface receiver = ERC23ContractInterface(_to);
      receiver.tokenFallback(msg.sender, _value, _data);
    }

    Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  // ERC23 compatible transfer function (2-arg, for backwards compatibility)
  function transfer(address _to, uint256 _value) public returns (bool success) {
    bytes memory empty;
    return transfer(_to, _value, empty);
  }
}

contract ERC677Token is StandardToken, ERC23Token {

  /* Approves and then calls the receiving contract */
  function approveAndCall(address _spender, uint256 _value, bytes _data) public returns (bool success) {
    super.approve(_spender, _value);

    // "it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead."
    require(ERC677Contract(_spender).receiveApproval(msg.sender, _value, this, _data));
    return true;
  }

  /* Transfers and then calls the receiving contract */
  function transferAndCall(address _to, uint256 _value, bytes _data) public returns (bool success) {
    super.transfer(_to, _value, _data);

    require(ERC677Contract(_to).receiveTransfer(msg.sender, _value, this, _data));
    return true;
  }

}

contract DonorToken is MintableToken, ERC23Token, ERC677Token {

  uint8 public constant decimals = 18; // default, can (and usually should) be overridden

}

contract MDToken is DonorToken {

  string public constant name = "MyDonorToken";
  string public constant symbol = "MDT";
  uint8 public constant decimals = 3;

}

