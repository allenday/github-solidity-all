pragma solidity ^0.4.18;

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {

    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner ) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value ) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  
}


/**
 * Math operations with safety checks
 */
library SafeMath {
  
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint) {
    return a < b ? a : b;
  }
  
}


/*
    Utilities & Common Modifiers
*/
contract Utils {
    /**
        constructor
    */
    function Utils() internal  {
    }

    // verifies that an amount is greater than zero
    modifier greaterThanZero(uint _amount) {
        require(_amount > 0);
        _;
    }

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    // verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

    // Overflow protected math functions

    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
    function safeDiv(uint a, uint b) internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
    
    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }
    
    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
    
}



/**
 *
 * Standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
 *
 */
contract StandardToken is ERC20, Utils {
    
    using SafeMath for uint256;
    
    uint256 _totalSupply = 0;
    
    /* Actual balances of token holders */
    mapping(address => uint256) balances;
    
    /* approve() allowances */
    mapping(address => mapping(address => uint256)) allowedSpendAmount;
    
    /* Interface declaration */
    function isToken() 
        public 
        pure 
        returns (bool) 
    {
        return true;
    }
  
    function totalSupply() 
        public 
        constant 
        returns (uint256) 
    {
        return _totalSupply;
    }
    
    function balanceOf(address _owner) 
        public
        constant
        validAddress(_owner)
        returns (uint256) 
    {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) 
        public
        validAddress(_to)
        returns (bool)
    {
        require(
            balances[msg.sender] >= _value
            && _value > 0
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value)
        public
        validAddress(_to)
        validAddress(_from)
        returns (bool)
    {
        require(
            allowedSpendAmount[_from][msg.sender] >= _value
            && balances[_from] >= _value
            && _value > 0
        );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowedSpendAmount[_from][msg.sender] = allowedSpendAmount[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value)
        public
        validAddress(_spender)
        returns (bool)
    {
        allowedSpendAmount[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender)
        public
        constant
        validAddress(_owner)
        validAddress(_spender)
        returns (uint256)
    {
        return allowedSpendAmount[_owner][_spender];
    }
  

}


/**
 * Upgrade agent interface inspired by Lunyr.
 *
 * Upgrade agent transfers tokens to a new version of a token contract.
 * Upgrade agent can be set on a token by the upgrade master.
 *
 * Steps are
 * - Upgradeabletoken.upgradeMaster calls UpgradeableToken.setUpgradeAgent()
 * - Individual token holders can now call UpgradeableToken.upgrade()
 *   -> This results to call UpgradeAgent.upgradeFrom() that issues new tokens
 *   -> UpgradeableToken.upgrade() reduces the original total supply based on amount of upgraded tokens
 *
 * Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
 */
 
contract UpgradeAgent {

    uint public originalSupply;
    
    /** Interface marker */
    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }
    
    /**
    * Upgrade amount of tokens to a new version.
    *
    * Only callable by UpgradeableToken.
    *
    * @param _tokenHolder Address that wants to upgrade its tokens
    * @param _amount Number of tokens to upgrade. The address may consider to hold back some amount of tokens in the old version.
    */
    function upgradeFrom(address _tokenHolder, uint _amount) external;
    
}

/**
 * 
 *  A token upgrade mechanism where users can opt-in amount of tokens to the next smart contract revision.
 *
 */
contract UpgradeableToken is StandardToken {

    /** Contract / person who can set the upgrade path. This can be the same as team multisig wallet, as what it is with its default value. */
    address internal upgradeMaster;

    /** The next contract where the tokens will be migrated. */
    UpgradeAgent internal _upgradeAgent;

    /** How many tokens we have upgraded by now. */
    uint internal totalUpgraded;

    /**
    * Upgrade states.
    *
    * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
    * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
    * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
    * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
    *
    */
    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

    /**
    * Somebody has upgraded some of his tokens.
    */
    event Upgrade(address indexed _from, address indexed _to, uint _value);

    /**
    * New upgrade agent available.
    */
    event UpgradeAgentSet(address agent);

    /**
    * Upgrade master updated.
    */
    event NewUpgradeMaster(address upgradeMaster);

    /**
    * Do not allow construction without upgrade master set.
    */
    function UpgradeableToken(address _upgradeMaster) public {
        upgradeMaster = _upgradeMaster;
        NewUpgradeMaster(upgradeMaster);
    }

    /**
    * Allow the token holder to upgrade some of their tokens to a new contract.
    */
    function upgrade(uint value) public {

        UpgradeState state = getUpgradeState();
        if(!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
            // Called in a bad state
            revert();
        }

        // Validate input value.
        if (value == 0) revert();

        balances[msg.sender] = balances[msg.sender].sub(value);

        // Take tokens out from circulation
        _totalSupply = _totalSupply.add(value);
        totalUpgraded = totalUpgraded.add(value);

        // Upgrade agent reissues the tokens
        _upgradeAgent.upgradeFrom(msg.sender, value);
        Upgrade(msg.sender, _upgradeAgent, value);
    }

    /**
    * Set an upgrade agent that handles
    */
    function setUpgradeAgent(address agent) external {

        if(!canUpgrade()) {
            // The token is not yet in a state that we could think upgrading
            revert();
        }

        if (agent == 0x0) revert();
        // Only a master can designate the next agent
        if (msg.sender != upgradeMaster) revert();
        // Upgrade has already begun for an agent
        if (getUpgradeState() == UpgradeState.Upgrading) revert();

        _upgradeAgent = UpgradeAgent(agent);

        // Bad interface
        if(!_upgradeAgent.isUpgradeAgent()) revert();
        // Make sure that token supplies match in source and target
        if (_upgradeAgent.originalSupply() != _totalSupply) revert();

        UpgradeAgentSet(_upgradeAgent);
    }

    /**
    * Get the state of the token upgrade.
    */
    function getUpgradeState() public constant returns(UpgradeState) {
        if(!canUpgrade()) return UpgradeState.NotAllowed;
        else if(address(_upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
        else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
        else return UpgradeState.Upgrading;
    }

    /**
    * Change the upgrade master.
    *
    * This allows us to set a new owner for the upgrade mechanism.
    */
    function setUpgradeMaster(address master) public {
        if (master == 0x0) revert();
        if (msg.sender != upgradeMaster) revert();
        upgradeMaster = master;
        NewUpgradeMaster(upgradeMaster);
    }

    /**
    * Child contract can enable to provide the condition when the upgrade can begun.
    */
    function canUpgrade() public pure returns(bool) {
        return true;
    }

}

/*
    Provides support and utilities for contract ownership
*/
contract ManagedToken is UpgradeableToken {

    address internal _owner;
    address internal newOwner;

    event OwnerUpdate(address _prevOwner, address _newOwner);
    
    /**
        @dev constructor
    */
    function ManagedToken() public UpgradeableToken(msg.sender) {
        _owner = msg.sender;
    }

    // allows execution by the _owner only
    modifier ownerOnly {
        assert(msg.sender == _owner);
        _;
    }

    /**
        @dev allows transferring the contract ownership
        the new owner still needs to accept the transfer
        can only be called by the contract owner

        @param _newOwner    new contract _owner
    */
    function transferOwnership(address _newOwner) 
        public 
        ownerOnly 
    {
        require(_newOwner != _owner);
        newOwner = _newOwner;
    }

    /**
        @dev used by a new _owner to accept an ownership transfer
    */
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(_owner, newOwner);
        _owner = newOwner;
        newOwner = 0x0;
    }
    
}


contract ARocketship is ManagedToken {
    
    bool internal _enginesRunning                           = false;
    bool internal _isFlying                                 = false;
    bool internal _autoDistributionViaETHContributions      = false;
    
    bool internal _foundationFirstRoundReleased             = false;
    
    uint internal _tokenSaleSupply                  = 6930000000000;
    uint internal _tokenSaleSupplyRemaining         = 6930000000000;
    
    uint internal _ecosystemSupply                  = 6930000000000;
    uint internal _ecosystemSupplyRemaining         = 6930000000000;
    uint internal _ecosystemSupplyRoundAmount       = 63500000000;
    uint internal _ecosystemReleaseRound            = 0;
    
    uint internal _foundationSupply                 = 6930000000000;
    uint internal _foundationSupplyRemaining        = 6930000000000;
    uint internal _foundationSupplyRound1           = 1044000000000;  
    uint internal _foundationSupplyRoundAmount      = 54000000000;
    uint internal _foundationReleaseRound           = 0;
    
    uint internal _feesAndBountySupply              = 210000000000;
    uint internal _feesAndBountySupplyRemaining     = 210000000000; 
    
    uint internal _currentStage                     = 0;
    uint internal _currentStageMaxSupply            = 0;
    uint internal _currentStageRemainingJM          = 0;
    uint internal _currentStageETHContributions     = 0;
    uint internal _JM_ETH_ExchangeRate              = 0;
    uint internal _maxETHContribution               = 0;
    uint internal _maxETHAutoContributions          = 0;
    
    uint internal _timeContractPublished            = block.timestamp;
    uint internal _releaseStartingLine              = 1514826000; //Monday, January 1, 2018 12:00:00 PM EST
    
    //Justmake (JM) Rocketship Reached Destination! (Token Sale Complete)
    bool internal _rocketshipReachedDestination     = false;
    
    
    /**
        This function starts the Justmake (JM) Rocketship. 
        
    */
    
    function startEngines() public ownerOnly {
        
        if(_enginesRunning == false) {
            
            _enginesRunning = true;
            EnginesAreRunning("The Justmake (JM) Rocketship Engines Are Running!!!!!!");
                    
        } else {
            revert();
        }
    
    }
    
    /**
        This Function Releases the 1st JM in the world to Shane Shook. He has been behind the 
        project since the beginning and asked if he could have the 1st Newly Minted Fresh Off
        The Press JM. Since he came up with the concept and no one else asked, we said sure
        this sounds like a great idea!!!
        
    */
    
    function blastOff(address _to) 
        public
        ownerOnly
        validAddress(_to)
        returns (bool)
    {
        
        if(_enginesRunning == true && _isFlying == false) {
            
            //Create First JM
            balances[_to] = 10000;
            
            //Update Total Suppy
            _totalSupply = safeAdd(_totalSupply, 10000);
            _feesAndBountySupplyRemaining = safeSub(_feesAndBountySupplyRemaining, 10000);
            
            _isFlying = true;
            
            BlastOff("The Justmake Token (JM) Rocketship Has Blasted Off and is Flying!!!!!!");    
            
            Transfer(this, _to, 10000);
            
            return true;
            
        } else {
            revert();
        }
        
    }
    
    function nextStage() public ownerOnly  {
        
        require(
            _enginesRunning == true &&
            _isFlying == true &&
            _currentStageRemainingJM == 0 &&
            _rocketshipReachedDestination == false
        );
        
        _currentStage = _currentStage.add(1);
            
        if(_currentStage == 1) {
            _currentStageMaxSupply = 693000000000;
        }
            
        if(_currentStage == 2) {
            _currentStageMaxSupply = 1039500000000;
        }
        
        if(_currentStage == 3) {
            _currentStageMaxSupply = 1386000000000;
        }
        
        if(_currentStage == 4) {
            _currentStageMaxSupply = 1732500000000;
        }
        
        if(_currentStage == 5) {
            _currentStageMaxSupply = 2079000000000;
        }
        
        if(_currentStage >= 1 && _currentStage <= 5) {
            _currentStageRemainingJM = _currentStageMaxSupply;
            _currentStageETHContributions = 0;
        } else {
            _currentStageRemainingJM = 0;
        }
        
    }
    
    function releaseTokenSaleJM(address _to, uint _jm) 
        public 
        ownerOnly
        validAddress(_to)
    {
        
        require(
            _enginesRunning == true &&
            _isFlying == true &&
            _currentStageMaxSupply > 0 &&
            _currentStageRemainingJM > 0 &&
            _jm > 0 &&
            _jm <= _currentStageRemainingJM &&
            _jm <= _tokenSaleSupplyRemaining &&
            _rocketshipReachedDestination == false
        );
        
        //Proceed with Manually Issuing JM
        balances[_to] = balances[_to].add(_jm);
        _currentStageRemainingJM = _currentStageRemainingJM.sub(_jm);
        _tokenSaleSupplyRemaining = _tokenSaleSupplyRemaining.sub(_jm);
        _totalSupply = _totalSupply.add(_jm);
        
        if(_tokenSaleSupplyRemaining == 0) {
            _rocketshipReachedDestination = true;
        }
        
        Transfer(this, _to, _jm);
        
    }
    
    function autoReleaseTokenSaleJM() public payable {
    
        require(_enginesRunning == true);
        require(_isFlying == true);
        require(_rocketshipReachedDestination == false);
        require(_autoDistributionViaETHContributions == true);
        require(_currentStageMaxSupply > 0);
        require(_currentStageRemainingJM > 0);
        require(_JM_ETH_ExchangeRate > 0);
        require(msg.value > 0);
        require(msg.value <= _maxETHContribution);
            
        //Proceed with Auto Issuing J
        uint _jm = msg.value.div(100000000000000);
        _jm = _jm.mul(_JM_ETH_ExchangeRate);
        
        require(_jm <= _currentStageRemainingJM);
        require(_jm <= _tokenSaleSupplyRemaining);
        require((_currentStageETHContributions + _jm) <= _maxETHAutoContributions);  
        
        _owner.transfer(msg.value);
        balances[msg.sender] = balances[msg.sender].add(_jm);
        
        _currentStageRemainingJM = _currentStageRemainingJM.sub(_jm);
        _tokenSaleSupplyRemaining = _tokenSaleSupplyRemaining.sub(_jm);
        _currentStageETHContributions = _currentStageETHContributions.add(_jm);
        _totalSupply = _totalSupply.add(_jm);
        
        if(_tokenSaleSupplyRemaining == 0) {
            _rocketshipReachedDestination = true;
        }
        
        Transfer(this, msg.sender, _jm);
        
    }

    function releaseFeesAndBountyJM(address _to, uint _jm) 
        public 
        ownerOnly
        validAddress(_to)
    {
        
        require(
            _enginesRunning == true &&
            _isFlying == true &&
            _jm > 0 &&
            _jm <= _feesAndBountySupply &&
            _jm <= _feesAndBountySupplyRemaining
        );
        
        //Proceed with Manually Issuing JM
        balances[_to] = balances[_to].add(_jm);
        _feesAndBountySupplyRemaining = _feesAndBountySupplyRemaining.sub(_jm);
        _totalSupply = _totalSupply.add(_jm);
        
        Transfer(this, _to, _jm);
        
    }
    
    function releaseFoundationJM(address _to) 
        public 
        ownerOnly
        validAddress(_to)
    {
        
        require(
            _enginesRunning == true &&
            _isFlying == true &&
            _rocketshipReachedDestination == true &&
            _foundationSupplyRemaining > 0 
        );
        
        //Release First Round to the Justmake Foundation after the Token Sale is Successful
        if(_foundationFirstRoundReleased == false) {
            
            balances[_to] = balances[_to].add(_foundationSupplyRound1);
            _foundationSupplyRemaining = _foundationSupplyRemaining.sub(_foundationSupplyRound1);
            _totalSupply = _totalSupply.add(_foundationSupplyRound1);
            Transfer(this, _to, _foundationSupplyRound1);
            
            _foundationFirstRoundReleased = true; 
               
        } else {
            
            require(block.timestamp >= _releaseStartingLine + (_foundationReleaseRound * 21 days));
                
            balances[_to] = balances[_to].add(_foundationSupplyRoundAmount);
            _foundationSupplyRemaining = _foundationSupplyRemaining.sub(_foundationSupplyRoundAmount);
            _totalSupply = _totalSupply.add(_foundationSupplyRoundAmount);
            Transfer(this, _to, _foundationSupplyRoundAmount);
            
            _foundationReleaseRound = _foundationReleaseRound.add(1);   
               
        }
        
    }

    function releaseEcosystemJM(address _to) 
        public 
        ownerOnly
        validAddress(_to)
    {
        
        require(
            _enginesRunning == true &&
            _isFlying == true &&
            _rocketshipReachedDestination == true &&
            _ecosystemSupplyRemaining > 0
        );
            
        require(block.timestamp >= _releaseStartingLine + (_ecosystemReleaseRound * 21 days));
        
        //Handle Last Round
        if(_ecosystemSupplyRemaining <= _ecosystemSupplyRoundAmount) {
            _ecosystemSupplyRoundAmount = _ecosystemSupplyRemaining;
        }
            
        balances[_to] = balances[_to].add(_ecosystemSupplyRoundAmount);
        _ecosystemSupplyRemaining = _ecosystemSupplyRemaining.sub(_ecosystemSupplyRoundAmount);
        _totalSupply = _totalSupply.add(_ecosystemSupplyRoundAmount);
        Transfer(this, _to, _ecosystemSupplyRoundAmount);
        
        _ecosystemReleaseRound = _ecosystemReleaseRound.add(1);     
        
    }
    
    function setAutoDistributionViaETHContributions(bool _bool) 
        public 
        ownerOnly 
    {
        require(_JM_ETH_ExchangeRate > 0);
        _autoDistributionViaETHContributions = _bool;
    }
    
    function setJMETHExchangeRate(uint _jm_no_decimals) 
        public 
        ownerOnly 
    {
        _JM_ETH_ExchangeRate = _jm_no_decimals;
    }

    function setMaxETHContribution(uint _wei) 
        public 
        ownerOnly 
    {
        _maxETHContribution = _wei;
    }
    
    function setMaxETHAutoContributions(uint _jm) 
        public 
        ownerOnly 
    {
        require(
            _jm >= 0 &&
            _jm <= _currentStageMaxSupply &&
            _jm <= _currentStageRemainingJM + _currentStageETHContributions
        );
        _maxETHAutoContributions = _jm;
    }
    
    function engineRunning() public view returns(bool) {
        return _enginesRunning;
    }
    
    function isFlying() public view returns(bool) {
        return _isFlying;
    }
    
    function autoDistributionViaETHContributions() public view returns(bool) {
        return _autoDistributionViaETHContributions;
    }
    
    function currentStage() public view returns(uint) {
        return _currentStage;
    }
    
    function currentStageMaxSupply() public view returns(uint) {
        return _currentStageMaxSupply;
    }
    
    function currentStageRemainingJM() public view returns(uint) {
        return _currentStageRemainingJM;
    } 
    
    function currentStageETHContributions() public view returns(uint) {
        return _currentStageETHContributions;
    }
    
    function tokenSaleSupplyRemaining() public view returns(uint) {
        return _tokenSaleSupplyRemaining;
    }
    
    function feesAndBountySupplyRemaining() public view returns(uint) {
        return _feesAndBountySupplyRemaining;
    }
    
    function ecosystemSupplyRemaining() public view returns(uint) {
        return _ecosystemSupplyRemaining;
    }
    
    function foundationSupplyRemaining() public view returns(uint) {
        return _foundationSupplyRemaining;
    }
    
    function JM_ETH_ExchangeRate() public view returns(uint) {
        return _JM_ETH_ExchangeRate;
    }
    
    function maxETHContribution() public view returns(uint) {
        return _maxETHContribution;
    }
    
    function maxETHAutoContributions() public view returns(uint) {
        return _maxETHAutoContributions;
    }
    
    function rocketshipReachedDestination() public view returns(bool) {
        return _rocketshipReachedDestination;
    }
    
    event EnginesAreRunning(string msg);
    event BlastOff(string msg);
    
}

contract JustmakeToken is ARocketship {

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;                             
    
    function () public payable {
        autoReleaseTokenSaleJM();
    }
    
    function JustmakeToken() public
    {
        _name           = "Justmake";
        _symbol         = "JM";
        _decimals       = 4;
        _totalSupply    = 0;
    }
    
    function name() public view returns (string) {
        return _name;
    }

    function symbol() public view returns (string) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }

}
