pragma solidity ^0.4.0;

contract owned {

    address public owner;
    address public candidate;

    function owned() payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _candidate) onlyOwner public {
        require(_candidate != 0);
        candidate = _candidate;
    }
    
    function confirmOwner() public {
        require(candidate == msg.sender);
        owner = candidate;
        delete candidate;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
    function transfer(address to, uint value);
    function allowance(address owner, address spender) constant returns (uint);
    function transferFrom(address from, address to, uint value);
    function approve(address spender, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}

/**
 * @title Know your customer contract
 */
contract KYC is owned {

    bool                      public enableAllTransfers;
    mapping (address => bool) public known;
    address                   public confirmer;

    function setConfirmer(address _confirmer) public onlyOwner {
        confirmer = _confirmer;
    }

    function setToKnown(address _who) public {
        require(msg.sender == confirmer || msg.sender == owner);
        known[_who] = true;
    }
    
    function setEnableAllTransfers(bool _enable) public onlyOwner {
        enableAllTransfers = _enable;
    }
}

/**
 * @title Crowdsale implementation
 */
contract Crowdsale is ERC20, KYC {

    uint    public etherPrice;
    address public crowdsaleOwner;
    uint    public totalLimitUSD;
    uint    public minimalSuccessUSD;
    uint    public collectedUSD;

    mapping (address => uint) internal balances;

    enum State { Disabled, PreICO, CompletePreICO, Crowdsale, Enabled, Migration }
    event NewState(State state);
    State   public state = State.Disabled;
    uint    public crowdsaleStartTime;
    uint    public crowdsaleFinishTime;

    modifier enabledState {
        require(state == State.Enabled);
        _;
    }

    struct Investor {
        uint amountTokens;
        uint amountWei;
    }
    mapping (address => Investor) public investors;
    mapping (uint => address)     public investorsIter;
    uint                          public numberOfInvestors;

    function Crowdsale() payable KYC() {}
    
    function () payable {
        require(state == State.PreICO || state == State.Crowdsale);
        require(now < crowdsaleFinishTime);
        require(known[msg.sender] == true);
        uint valueWei = msg.value;
        uint valueUSD = valueWei * etherPrice / 1000000000000000000;
        if (collectedUSD + valueUSD > totalLimitUSD) { // don't need so much ether
            valueUSD = totalLimitUSD - collectedUSD;
            valueWei = valueUSD * 1000000000000000000 / etherPrice;
            require(msg.sender.call.gas(3000000).value(msg.value - valueWei)());
            collectedUSD = totalLimitUSD; // to be sure!
        } else {
            collectedUSD += valueUSD;
        }
        mintTokens(msg.sender, valueUSD, valueWei);
    }

    function depositUSD(address _who, uint _valueUSD) public onlyOwner {
        require(state == State.PreICO || state == State.Crowdsale);
        require(now < crowdsaleFinishTime);
        require(known[_who] == true);
        require(collectedUSD + _valueUSD <= totalLimitUSD);
        collectedUSD += _valueUSD;
        mintTokens(_who, _valueUSD, 0);
    }

    function mintTokens(address _who, uint _valueUSD, uint _valueWei) internal {
        uint tokensPerUSD = 100;
        if (state == State.PreICO) {
                tokensPerUSD = 150;
        } else if (state == State.Crowdsale) {
            if (now < crowdsaleStartTime + 1 days) {
                tokensPerUSD = 120;
            } else if (now < crowdsaleStartTime + 1 weeks) {
                tokensPerUSD = 110;
            }
        }
        uint tokens = tokensPerUSD * _valueUSD;
        require(balances[_who] + tokens > balances[_who]); // overflow
        require(tokens > 0);
        Investor storage inv = investors[_who];
        if (inv.amountTokens == 0) { // new investor
            investorsIter[numberOfInvestors++] = _who;
        }
        inv.amountTokens += tokens;
        inv.amountWei += _valueWei;
        balances[_who] += tokens;
        Transfer(this, _who, tokens);
        totalSupply += tokens;
    }
    
    function startTokensSale(
            address _crowdsaleOwner,
            uint    _crowdsaleDurationDays,
            uint    _totalLimitUSD,
            uint    _minimalSuccessUSD,
            uint    _etherPrice) public onlyOwner {
        require(state == State.Disabled || state == State.CompletePreICO);
        crowdsaleStartTime = now;
        crowdsaleOwner = _crowdsaleOwner;
        etherPrice = _etherPrice;
        delete numberOfInvestors;
        delete collectedUSD;
        crowdsaleFinishTime = now + _crowdsaleDurationDays * 1 days;
        totalLimitUSD = _totalLimitUSD;
        minimalSuccessUSD = _minimalSuccessUSD;
        if (state == State.Disabled) {
            state = State.PreICO;
        } else {
            state = State.Crowdsale;
        }
        NewState(state);
    }
    
    function timeToFinishTokensSale() public constant returns(uint t) {
        require(state == State.PreICO || state == State.Crowdsale);
        if (now > crowdsaleFinishTime) {
            t = 0;
        } else {
            t = crowdsaleFinishTime - now;
        }
    }
    
    function finishTokensSale(uint _investorsToProcess) public {
        require(state == State.PreICO || state == State.Crowdsale);
        require(now >= crowdsaleFinishTime || collectedUSD == totalLimitUSD ||
            (collectedUSD >= minimalSuccessUSD && msg.sender == owner));
        if (collectedUSD < minimalSuccessUSD) {
            // Investors can get their ether calling withdrawBack() function
            while (_investorsToProcess > 0 && numberOfInvestors > 0) {
                address addr = investorsIter[--numberOfInvestors];
                Investor memory inv = investors[addr];
                balances[addr] -= inv.amountTokens;
                totalSupply -= inv.amountTokens;
                Transfer(addr, this, inv.amountTokens);
                --_investorsToProcess;
                delete investorsIter[numberOfInvestors];
            }
            if (numberOfInvestors > 0) {
                return;
            }
            if (state == State.PreICO) {
                state = State.Disabled;
            } else {
                state = State.CompletePreICO;
            }
        } else {
            while (_investorsToProcess > 0 && numberOfInvestors > 0) {
                --numberOfInvestors;
                --_investorsToProcess;
                delete investors[investorsIter[numberOfInvestors]];
                delete investorsIter[numberOfInvestors];
            }
            if (numberOfInvestors > 0) {
                return;
            }
            if (state == State.PreICO) {
                state = State.CompletePreICO;
                require(crowdsaleOwner.call.gas(3000000).value(this.balance)());
            } else {
                require(crowdsaleOwner.call.gas(3000000).value(this.balance)());
                // Create additional tokens for owner (12% of complete totalSupply)
                uint tokens = 12 * totalSupply / 88;
                balances[owner] = tokens;
                totalSupply += tokens;
                Transfer(this, owner, tokens);
                state = State.Enabled;
            }
        }
        NewState(state);
    }
    
    // This function must be called by token holder in case of crowdsale failed
    function withdrawBack() public {
        require(state == State.Disabled || state == State.CompletePreICO);
        uint value = investors[msg.sender].amountWei;
        if (value > 0) {
            delete investors[msg.sender];
            require(msg.sender.call.gas(3000000).value(value)());
        }
    }
}

/**
 * @title Token BRAIN implementation
 */
contract Token is Crowdsale {
    
    string  public standard    = 'Token 0.1';
    string  public name        = 'NeuroProtect';
    string  public symbol      = "BRAIN";
    uint8   public decimals    = 0;

    mapping (address => mapping (address => uint)) public allowed;

    event Burn(address indexed who, uint value);

    // Fix for the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    function Token() payable Crowdsale() {}

    function balanceOf(address who) constant returns (uint) {
        return balances[who];
    }

    function transfer(address _to, uint _value)
        public enabledState onlyPayloadSize(2 * 32) {
        require(enableAllTransfers || known[_to] == true);
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]); // overflow
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint _value)
        public enabledState onlyPayloadSize(3 * 32) {
        require(enableAllTransfers || known[_to] == true);
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]); // overflow
        require(allowed[_from][msg.sender] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public enabledState {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public constant enabledState
        returns (uint remaining) {
        return allowed[_owner][_spender];
    }
    
    function burn(address _who, uint _value) public enabledState {
        require(known[_who] == true);
        require(balances[_who] >= _value);
        balances[_who] -= _value;
        totalSupply -= _value;
        Burn(_who, _value);
    }
}

/**
 * @title Migration agent intefrace for possibility of moving tokens
 *        to another contract
 */
contract MigrationAgent {
    function migrateFrom(address _from, uint _value);
}

/**
 * @title Migration functionality for possibility of moving tokens
 *        to another contract
 */
contract NeuroProtect is Token {
    
    uint    public totalMigrated;
    address public migrationAgent;

    event Migrate(address indexed from, address indexed to, uint value);

    function NeuroProtect() payable Token() {}

    // Migrate _value of tokens to the new token contract
    function migrate() external {
        require(state == State.Migration);
        uint value = balances[msg.sender];
        balances[msg.sender] -= value;
        Transfer(msg.sender, this, value);
        totalSupply -= value;
        totalMigrated += value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
        Migrate(msg.sender, migrationAgent, value);
    }

    function setMigrationAgent(address _agent) external onlyOwner {
        require(migrationAgent == 0 && _agent != 0);
        migrationAgent = _agent;
    }
}
