pragma solidity ^0.4.18;

// File: contracts/supporting/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: contracts/supporting/TruAddress.sol

/// @title TruAddress
/// @dev Tru Address - Library of helper functions surrounding the Address type in Solidity
/// @author Ian Bray




library TruAddress {
    
    using SafeMath for uint256;
    using SafeMath for uint;

    /// @dev Function to validate that a supplied Address is valid 
    /// (that is is 20 bytes long and it is not empty or 0x0)
    /// @return Returns true if the address is structurally a valid ethereum address and not 0x0; 
    /// returns false otherwise
    function isValid(address input) public pure returns (bool) {
        uint addrLength = addressLength(address(input));
        return ((addrLength == 20) && (input != address(0)));
    }

    /// @dev Function convert a Address to a String
    /// @return Address as a string
    function toString(address input) internal pure returns (string) {
        bytes memory byteArray = new bytes(20);
        for (uint i = 0; i < 20; i++) {
            byteArray[i] = byte(uint8(uint(input) / (2**(8*(19 - i)))));
        }
        return string(byteArray);
    }

    /// @dev Function to return the length of a given Address
    /// @return Length of the address as a uint
    function addressLength(address input) internal pure returns (uint) {
        string memory addressStr = toString(input);
        return bytes(addressStr).length;
    }
}

// File: contracts/supporting/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/supporting/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/supporting/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 * @dev zeppelin-solidity's Basic Token (https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/BasicToken.sol)
 */





/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: contracts/supporting/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 * @dev Based off of Open-Zeppelin's ERC20 Token (https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20.sol)
 * @dev Updated by Tru Ltd November 2017 to comply with Solidity 0.4.18 syntax and Best Practices
 */





/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/supporting/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

// File: contracts/supporting/ReleasableToken.sol

/// @title ReleasableToken
/// @notice Abstract token contract to allow tokens to only be transferable after a release event.
/// This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
/// Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
/// Updated by Tru Ltd November 2017 to comply with Solidity 0.4.18 syntax and Best Practices
/// @author TokenMarket Ltd/Updated by Ian Bray, Tru Ltd





contract ReleasableToken is StandardToken, Ownable {

    address public releaseAgent;

    bool public released = false;

    /// @notice Event when a Token is released
    event Released();

    /// @notice Event when a Release Agent is set for the token
    /// @param releaseAgent Address of Release Agent
    event ReleaseAgentSet(address releaseAgent);

    /// @notice Event when a Transfer Agent is set or updated for the token
    /// @param transferAgent Address of new Transfer Agent
    /// @param status Whether Transfer Agent is enabled or disabled
    event TransferAgentSet(address transferAgent, bool status);

    /** Map of agents that are allowed to transfer tokens regardless of the lock down period. 
    * These are crowdsale contracts and possible the team multisig itself. 
    */
    mapping (address => bool) public transferAgents;

    /// @notice Limit token transfer until the crowdsale is over.
    modifier canTransfer(address _sender) {
        require(released || transferAgents[_sender]);
        _;
    }

    /// @notice The function can be called only before or after the tokens have been released
    modifier inReleaseState(bool releaseState) {
        require(releaseState == released);
        _;
    }

    /// @notice The function can be called only by a whitelisted release agent.
    modifier onlyReleaseAgent() {
        require(msg.sender == releaseAgent);
        _;
    }

    /// @notice Set the contract that can call release and make the token transferable.
    /// @dev Design choice. Allow reset the release agent to fix fat finger mistakes.
    function setReleaseAgent(address addr) public onlyOwner inReleaseState(false) {
        ReleaseAgentSet(addr);
        // We don't do interface check here as we might want to a normal wallet address to act as a release agent
        releaseAgent = addr;
    }

    /// @notice Owner can allow a particular address (a crowdsale contract) to transfer tokens despite the lock up period.
    function setTransferAgent(address addr, bool state) public onlyOwner inReleaseState(false) {
        TransferAgentSet(addr, state);
        transferAgents[addr] = state;
    }
    /// @notice One way function to release the tokens to the wild.
    /// @dev Can be called only from the release agent that is the final Crowdsale contract. 
    /// It is only called if the crowdsale has been success (first milestone reached).
    function releaseTokenTransfer() public onlyReleaseAgent {
        Released();
        released = true;
    }

    /// @notice override of StandardToken transfer function to include canTransfer modifier
    /// @param _to address to send _value of tokens to
    /// @param _value Value of tokens to send to _to address
    function transfer(address _to, 
                      uint _value) public canTransfer(msg.sender) returns (bool success) {
        // Call StandardToken.transfer()
        return super.transfer(_to, _value);
    }

    /// @notice override of StandardToken transferFrom function to include canTransfer modifier
    /// @param _from address to send _value of tokens from
    /// @param _to address to send _value of tokens to
    /// @param _value Value of tokens to send to _to address
    function transferFrom(address _from, 
                          address _to, 
                          uint _value) public canTransfer(_from) returns (bool success) {
        // Call StandardToken.transferFrom()
        return super.transferFrom(_from, _to, _value);
    }
}

// File: contracts/supporting/TruMintableToken.sol

/// @title TruMintableToken
/// @notice A mintable token - forked from Open-Zeppelin Mintable Token to include 
/// TokenMarket Ltd's ReleaseableToken's functionality
/// @dev - Based off of zeppelin-solidity's Mintable Token 
/// (https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/MintableToken.sol)
/// - Based off of TokenMarket's ReleasableToken 
/// (https://github.com/TokenMarketNet/ico/blob/master/contracts/ReleasableToken.sol).
/// Updated by Tru Ltd October 2017 to comply with Solidity 0.4.18 syntax and Best Practices
/// and to meet requirements of the Tru Reputation Token
/// @author Ian Bray






contract TruMintableToken is ReleasableToken {
    
    using SafeMath for uint256;
    using SafeMath for uint;

    bool public mintingFinished = false;

    bool public preSaleComplete = false;

    bool public saleComplete = false;

    event Minted(address indexed _to, uint256 _amount);

    event MintFinished(address indexed _executor);
    
    event PreSaleComplete(address indexed _executor);

    event SaleComplete(address indexed _executor);

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /// @dev Function to mint tokens
    /// @param _to The address that will receive the minted tokens.
    /// @param _amount The amount of tokens to mint.
    /// @return A boolean that indicates if the operation was successful.
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        require(_amount > 0);
        require(TruAddress.isValid(_to));
    
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Minted(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /// @dev Function to stop minting new tokens.
    /// @return True if the operation was successful.
    function finishMinting(bool _presale, bool _sale) public onlyOwner returns (bool) {
        // Require at least one argument to be true
        require(_sale != _presale);

        /// @dev If _presale is true, require _sale to be false and mark the Pre Sale as Complete
        if (_presale == true) {
            preSaleComplete = true;
            PreSaleComplete(msg.sender);
            return true;
        }

        /// @dev Else, require preSaleComplete to be true and mark the CrowdSale as Complete
        require(preSaleComplete == true);
        saleComplete = true;
        SaleComplete(msg.sender);
        mintingFinished = true;
        MintFinished(msg.sender);
        return true;
    }
}

// File: contracts/supporting/UpgradeAgent.sol

/// @title UpgradeAgent
/// @notice Upgrade agent interface inspired by Lunyr that transfers tokens to a new contract.
/// Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
/// This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
/// Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
/// Updated by Tru Ltd November 2017 to comply with Solidity 0.4.18 syntax and Best Practices
/// @author TokenMarket Ltd/Updated by Ian Bray, Tru Ltd


contract UpgradeAgent {
    
    uint public originalSupply;

    /// @notice Function interface to check if it is an upgradeAgent
    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    /// @notice Function interface for upgrading a token from an address
    /// @param _from Origin address of tokens to upgrade
    /// @param _value Number of tokens to upgrade
    function upgradeFrom(address _from, uint256 _value) public;
}

// File: contracts/supporting/TruUpgradeableToken.sol

/// @title Tru Upgradeable Token
/// @notice A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
/// @dev This Smart Contract is based upon UpgradeableToken by TokenMarket Ltd. The original source can be found
/// at https://raw.githubusercontent.com/TokenMarketNet/ico/master/contracts/UpgradeableToken.sol
/// It has been updated for Tru Ltd's purposes in November 2017 and compiles with solidity 0.4.18's syntax
/// @author Ian Bray, Tru Ltd/Original: TokenMarket Ltd







contract TruUpgradeableToken is StandardToken {

    using SafeMath for uint256;
    using SafeMath for uint;

    /// @notice Contract / person who can set the upgrade path.
    address public upgradeMaster;

    /// @notice The Contract that the target will be upgraded to
    UpgradeAgent public upgradeAgent;

    /// @notice Total Number of upgraded tokens
    uint256 public totalUpgraded;

    /// @notice Whether the Contract is upgradeable
    bool private isUpgradeable = true;

    /**
     * Upgrade states.
     *
     * - NotAllowed: The child contract has not reached a condition where the upgrade can begin
     * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
     * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
     * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
     *
    */
    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

    /// @notice Event to notify when a token holder upgrades their tokens
    /// @param to Destination address of upgraded tokens (should always be upgradeAgent)
    /// @param upgradeValue Number of tokens being upgraded
    event Upgrade(address indexed from, 
        address indexed to, 
        uint256 upgradeValue);

    /// @notice Event to notify when an upgradeAgent is set
    /// @param agent upgradeAgent address
    /// @param executor Address which set the upgradeAgent
    event UpgradeAgentSet(address indexed agent, 
        address indexed executor);

    /// @notice Event to notify the new total number of tokens that have been
    /// @param originalBalance Balance of Upgrade Tokens before
    /// @param newBalance Balance of Upgrade Tokens after
    /// @param executor AAddress that executed the token upgrade
    event NewUpgradedAmount(uint256 originalBalance, 
        uint256 newBalance, 
        address indexed executor);
    
    /// @notice Modifier to only allow the Upgrade Master to execute the function
    modifier onlyUpgradeMaster() {
        require(msg.sender == upgradeMaster);
        _;
    }

    /**
     * Constructor
    */
    function TruUpgradeableToken(address _upgradeMaster) public {

        require(TruAddress.isValid(_upgradeMaster));
        upgradeMaster = _upgradeMaster;
    }

    /**
     * Allow the token holder to upgrade some of their tokens to a new contract.
    */
    function upgrade(uint256 _value) public {
        UpgradeState state = getUpgradeState();
        require((state == UpgradeState.ReadyToUpgrade) || (state == UpgradeState.Upgrading));
        require(_value > 0);
        require(balances[msg.sender] >= _value);

        uint256 upgradedAmount = totalUpgraded.add(_value);

        uint256 senderBalance = balances[msg.sender];
        uint256 newSenderBalance = senderBalance.sub(_value);      
        uint256 newTotalSupply = totalSupply.sub(_value);
        balances[msg.sender] = newSenderBalance;
        totalSupply = newTotalSupply;        
        NewUpgradedAmount(totalUpgraded, newTotalSupply, msg.sender);
        totalUpgraded = upgradedAmount;
        // Upgrade agent reissues the tokens
        upgradeAgent.upgradeFrom(msg.sender, _value);
        Upgrade(msg.sender, upgradeAgent, _value);
    }

    /**
     * Set an upgrade agent that handles
    */
    function setUpgradeAgent(address _agent) public onlyUpgradeMaster {
        require(TruAddress.isValid(_agent));
        require(canUpgrade());
        require(getUpgradeState() != UpgradeState.Upgrading);

        UpgradeAgent newUAgent = UpgradeAgent(_agent);

        require(newUAgent.isUpgradeAgent());
        require(newUAgent.originalSupply() == totalSupply);

        UpgradeAgentSet(upgradeAgent, msg.sender);

        upgradeAgent = newUAgent;
    }

    /**
     * Get the state of the token upgrade.
    */
    function getUpgradeState() public constant returns(UpgradeState) {
        if (!canUpgrade())
            return UpgradeState.NotAllowed;
        else if (upgradeAgent == address(0))
            return UpgradeState.WaitingForAgent;
        else if (totalUpgraded == 0)
            return UpgradeState.ReadyToUpgrade;
        else 
            return UpgradeState.Upgrading;
    }

    /**
     * Change the upgrade master.
     *
     * This allows us to set a new owner for the upgrade mechanism.
    */
    function setUpgradeMaster(address _master) public onlyUpgradeMaster {
        require(TruAddress.isValid(_master) == true);
        upgradeMaster = _master;
    }

    /**
     * Child contract can enable to provide the condition when the upgrade can begun.
    */
    function canUpgrade() public constant returns(bool) {
        return isUpgradeable;
    }
}

// File: contracts/TruReputationToken.sol

/// @title Tru Reputation Token
/// @notice Tru Reputation Protocol ERC20 compliant Token
/// @author Ian Bray







contract TruReputationToken is TruMintableToken, TruUpgradeableToken {

    using SafeMath for uint256;
    using SafeMath for uint;

    /// @notice number of decimals for the Token - 18
    uint8 public constant decimals = 18;

    /// @notice name of the Token - Tru Reputation Token
    string public constant name = "Tru Reputation Token";

    /// @notice Symbol of the Token - TRU
    string public constant symbol = "TRU";

    /// @notice Address of Tru Advisory Board
    address public execBoard = 0x0;

    /// @notice Event to notify when the execBoard address changes
    /// @param oldAddress old address of the execBoard
    /// @param newAddress old address of the execBoard
    /// @param executor Account that executed the change
    event BoardAddressChanged(address indexed oldAddress, 
        address indexed newAddress, 
        address indexed executor);

    /// @notice Modifier to only allow the Tru Advisory Board MultiSig Wallet to execute the function
    modifier onlyExecBoard() {
        require(msg.sender == execBoard);
        _;
    }

    /// @notice Constructor for TruReputationToken Contract
    function TruReputationToken() public TruUpgradeableToken(msg.sender) {
        execBoard = msg.sender;
        BoardAddressChanged(0x0, msg.sender, msg.sender);
    }
    
    /// @notice Function to change the address of the Tru Advisory Board
    /// @dev Can only be executed by the Current Tru Advisory Board
    /// @param _newAddress New address of the Tru Advisory Board
    function changeBoardAddress(address _newAddress) public onlyExecBoard {
        require(TruAddress.isValid(_newAddress));
        require(_newAddress != execBoard);
        address oldAddress = execBoard;
        execBoard = _newAddress;
        BoardAddressChanged(oldAddress, _newAddress, msg.sender);
    }

    /// @notice Function to check if this token contract can be upgraded
    function canUpgrade() public constant returns(bool) {
        return released && super.canUpgrade();
    }

    /// @notice Function to set Upgrade Master of this contract
    /// @dev can only be set by current contract owner
    /// @param _master Address of the Upgrade Master contract
    function setUpgradeMaster(address _master) public onlyOwner {
        super.setUpgradeMaster(_master);
    }
}
