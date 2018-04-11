pragma solidity 0.4.21;

/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns(uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns(uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns(uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns(uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/// @title ERC20Basic
/// @dev Simpler version of ERC20 interface
/// @dev see https://github.com/ethereum/EIPs/issues/179
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/// @title ERC20 interface
/// @dev see https://github.com/ethereum/EIPs/issues/20
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/// @title Basic token
/// @dev Basic version of StandardToken, with no allowances.
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) public balances;

  /// @dev transfer token for a specified address
  /// @param _to The address to transfer to.
  /// @param _value The amount to be transferred.
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /// @dev Gets the balance of the specified address.
  /// @param _owner The address to query the the balance of.
  /// @return An uint256 representing the amount owned by the passed address.
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}


/// @title Standard ERC20 token
/// @dev Implementation of the basic standard token.
/// @dev https://github.com/ethereum/EIPs/issues/20
/// @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) allowed;

  /// @dev Transfer tokens from one address to another
  /// @param _from address The address which you want to send tokens from
  /// @param _to address The address which you want to transfer to
  /// @param _value uint256 the amount of tokens to be transferred
  function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
  /// Beware that changing an allowance with this method brings the risk that someone may use both the old
  /// and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  /// race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  /// @param _spender The address which will spend the funds.
  /// @param _value The amount of tokens to be spent.
  function approve(address _spender, uint256 _value) public returns(bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Function to check the amount of tokens that an owner allowed to a spender.
  /// @param _owner address The address which owns the funds.
  /// @param _spender address The address which will spend the funds.
  /// @return A uint256 specifying the amount of tokens still available for the spender.
  function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /// approve should be called when allowed[_spender] == 0. To increment
  /// allowed value is better to use this function to avoid 2 calls (and wait until
  /// the first transaction is mined)
  /// From MonolithDAO Token.sol
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];

    if(_subtractedValue > oldValue)
      allowed[msg.sender][_spender] = 0;
    else
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}


/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @dev The Ownable constructor sets the original `owner` of the contract to the sender
  /// account.
  function Ownable() {
    owner = msg.sender;
  }

  /// @dev Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /// @dev Allows the current owner to transfer control of the contract to a newOwner.
  /// @param newOwner The address to transfer ownership to.
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


/// @title Pausable
/// @dev Base contract which allows children to implement an emergency stop mechanism.
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  /// @dev Modifier to make a function callable only when the contract is not paused.
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /// @dev Modifier to make a function callable only when the contract is paused.
  modifier whenPaused() {
    require(paused);
    _;
  }

  /// @dev called by the owner to pause, triggers stopped state
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /// @dev called by the owner to unpause, returns to normal state
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


/// @title Pausable token
/// @dev StandardToken modified with pausable transfers.
contract PausableToken is StandardToken, Pausable {
  function transfer(address _to, uint256 _value) public whenNotPaused returns(bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns(bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns(bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns(bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns(bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}


/// @title This is the token called Drops for Fluid AI. It's pausable which means
/// that the owner of the token can block transfers in case we find severe vulnerabilities
/// or the contract is hacked.
/// @author Merunas Grincalaitis <merunasgrincalaitis@gmail.com>
contract Drops is PausableToken {
   string public constant name = 'Drops';

   string public constant symbol = 'AQUA';

   uint8 public constant decimals = 18;

   // 89.5 million tokens with 18 decimals maximum
   uint256 public totalSupply = 89.5e24;

   // The amount of tokens to distribute on the crowsale
   uint256 public constant crowdsaleTokens = 44.5e24;

   uint256 public ICOEndTime;

   address public crowdsale;

   uint256 public tokensRaised;

    mapping(address => bool) public isWhitelisted;

   // Only allow token transfers after the ICO
   modifier afterCrowdsale() {
      require(now >= ICOEndTime || tokensRaised >= crowdsaleTokens || msg.sender == owner || isWhitelisted[msg.sender]);
      _;
   }

   // Only the crowdsale
   modifier onlyCrowdsale() {
      require(msg.sender == crowdsale);
      _;
   }

   /// @notice The constructor used to set the initial balance for the founder and development
   /// the owner of those tokens will distribute the tokens for development and platform
   /// @param _ICOEndTime When will the ICO end to allow token transfers after the ICO only,
   /// required parameter
   function Drops(uint256 _ICOEndTime) public {
      require(_ICOEndTime > 0);

      balances[owner] = totalSupply;
      ICOEndTime = _ICOEndTime;
      isWhitelisted[owner] = true;
   }

   /// @notice To set the address of the crowdsale in order to distribute the tokens
   /// @param _crowdsale The address of the crowdsale
   function setCrowdsaleAddress(address _crowdsale) public onlyOwner {
      require(_crowdsale != address(0));

      crowdsale = _crowdsale;
   }

   function addWhitelisted() public onlyOwner {
       isWhitelisted[msg.sender] = true;
   }

   function removeWhitelisted() public onlyOwner {
       isWhitelisted[msg.sender] = false;
   }

   /// @notice To distribute the presale and ICO tokens and increase the total
   /// supply accordingly. The unsold tokens will be deleted, not generated
   /// @param _to The user that will receive the tokens
   /// @param _amount How many tokens he'll receive
   function distributeTokens(address _to, uint256 _amount) public onlyCrowdsale {
      require(_to != address(0));
      require(_amount > 0);
      require(tokensRaised.add(_amount) <= crowdsaleTokens);

      tokensRaised = tokensRaised.add(_amount);
      balances[owner] = balances[owner].sub(_amount);
      balances[_to] = balances[_to].add(_amount);
   }

   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function transfer(address _to, uint256 _value) public whenNotPaused afterCrowdsale returns(bool) {
      return super.transfer(_to, _value);
   }

   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused afterCrowdsale returns(bool) {
      return super.transferFrom(_from, _to, _value);
   }

   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function approve(address _spender, uint256 _value) public whenNotPaused afterCrowdsale returns(bool) {
     return super.approve(_spender, _value);
   }

   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function increaseApproval(address _spender, uint _addedValue) public whenNotPaused afterCrowdsale returns(bool success) {
     return super.increaseApproval(_spender, _addedValue);
   }

   /// @notice Override the functions to not allow token transfers until the end of the ICO
   function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused afterCrowdsale returns(bool success) {
     return super.decreaseApproval(_spender, _subtractedValue);
   }

   function emergencyExtract() external onlyOwner {
       owner.transfer(this.balance);
   }
}
