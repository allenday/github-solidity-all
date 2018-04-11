pragma solidity ^0.4.0;

contract owned {

    address public owner;
    address public newOwner;

    function owned() payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        require(_owner != 0);
        newOwner = _owner;
    }
    
    function confirmOwner() public {
        require(newOwner == msg.sender);
        owner = newOwner;
        delete newOwner;
    }
}

contract Crowdsale is owned {
    
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    uint    public etherPrice;
    address public crowdsaleOwner;
    uint    public totalLimitUSD;
    uint    public minimalSuccessUSD;
    uint    public collectedUSD;

    enum State { Disabled, PreICO, CompletePreICO, Crowdsale, Enabled, Migration }
    event NewState(State state);
    State   public state = State.Disabled;
    uint    public crowdsaleStartTime;
    uint    public crowdsaleFinishTime;

    modifier enabledState {
        require(state == State.Enabled);
        _;
    }

    modifier enabledOrMigrationState {
        require(state == State.Enabled || state == State.Migration);
        _;
    }

    struct Investor {
        uint256 amountTokens;
        uint    amountWei;
    }
    mapping (address => Investor) public investors;
    mapping (uint => address)     public investorsIter;
    uint                          public numberOfInvestors;
    
    function () payable {
        require(state == State.PreICO || state == State.Crowdsale);
        uint256 tokensPer10USD = 100;
        uint valueWei = msg.value;
        uint valueUSD = valueWei * etherPrice / 1000000000000000000;
        if (state == State.PreICO) {
            if (valueUSD >= 100000) {
                tokensPer10USD = 200;
            } else {
                tokensPer10USD = 175;
            }
        } else if (state == State.Crowdsale) {
            if (now < crowdsaleStartTime + 1 days || valueUSD >= 100000) {
                tokensPer10USD = 150;
            } else if (now < crowdsaleStartTime + 1 weeks) {
                tokensPer10USD = 125;
            }
        }

        if (collectedUSD + valueUSD > totalLimitUSD) { // don't need so much ether
            valueUSD = totalLimitUSD - collectedUSD;
            valueWei = valueUSD * 1000000000000000000 / etherPrice;
            msg.sender.transfer(msg.value - valueWei);
            collectedUSD = totalLimitUSD; // to be sure!
        } else {
            collectedUSD += valueUSD;
        }
        
        uint256 tokens = tokensPer10USD * valueUSD / 10;
        require(balanceOf[msg.sender] + tokens > balanceOf[msg.sender]); // overflow
        require(tokens > 0);
            
        Investor storage inv = investors[msg.sender];
        if (inv.amountWei == 0) { // new investor
            investorsIter[numberOfInvestors++] = msg.sender;
        }
        inv.amountTokens += tokens;
        inv.amountWei += valueWei;
        balanceOf[msg.sender] += tokens;
        totalSupply += tokens;
        Transfer(this, msg.sender, tokens);
    }
    
    function startTokensSale(address _crowdsaleOwner, uint _etherPrice) public onlyOwner {
        require(state == State.Disabled || state == State.CompletePreICO);
        crowdsaleStartTime = now;
        crowdsaleOwner = _crowdsaleOwner;
        etherPrice = _etherPrice;
        delete numberOfInvestors;
        delete collectedUSD;
        if (state == State.Disabled) {
            crowdsaleFinishTime = now + 14 days;
            state = State.PreICO;
            totalLimitUSD = 1000000;
            minimalSuccessUSD = 0;
        } else {
            crowdsaleFinishTime = now + 30 days;
            state = State.Crowdsale;
            totalLimitUSD = 99750000;
            minimalSuccessUSD = 7000000;
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
        require(now >= crowdsaleFinishTime || collectedUSD == totalLimitUSD);
        if (collectedUSD < minimalSuccessUSD) {
            // Investors can get their ether calling withdrawBack() function
            while (_investorsToProcess > 0 && numberOfInvestors > 0) {
                address addr = investorsIter[--numberOfInvestors];
                Investor memory inv = investors[addr];
                balanceOf[addr] -= inv.amountTokens;
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
            crowdsaleOwner.transfer(this.balance);
            if (state == State.PreICO) {
                state = State.CompletePreICO;
            } else {
                uint256 extraEmission = 2 * totalSupply / 5;
                balanceOf[crowdsaleOwner] = extraEmission;
                Transfer(this, crowdsaleOwner, extraEmission);

                extraEmission = 3 * totalSupply / 5;
                balanceOf[this] = extraEmission;
                Transfer(this, this, extraEmission);

                totalSupply *= 2;
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
            msg.sender.transfer(value);
        }
    }
}

contract Token is Crowdsale {
    
    string  public standard    = 'Token 0.1';
    string  public name        = 'OpenLongevity';
    string  public symbol      = "YEAR";
    uint8   public decimals    = 0;

    modifier onlyTokenHolders {
        require(balanceOf[msg.sender] != 0);
        _;
    }

    mapping (address => mapping (address => uint256)) public allowed;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function Token() payable Crowdsale() {}

    function transfer(address _to, uint256 _value) public enabledState {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]); // overflow
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public enabledState {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]); // overflow
        require(allowed[_from][msg.sender] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public enabledState {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public constant enabledState
        returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

contract TokenMigration is Token {
    
    address public migrationAgent;
    uint256 public totalMigrated;

    event Migrate(address indexed from, address indexed to, uint256 value);

    function TokenMigration() payable Token() {}

    // Migrate _value of tokens to the new token contract
    function migrate(uint256 _value) external {
        require(state == State.Migration);
        require(migrationAgent != 0);
        require(_value != 0);
        require(_value <= balanceOf[msg.sender]);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

    function setMigrationAgent(address _agent) external onlyOwner {
        require(migrationAgent == 0);
        migrationAgent = _agent;
        state = State.Migration;
    }
}

contract OpenLongevity is TokenMigration {

    enum Vote { NoVote, VoteYea, VoteNay }
    uint public deploymentPriceYear = 1;

    function OpenLongevity() payable TokenMigration() {}

    event Deployed(address indexed projectOwner, uint proofReqFund, string urlInfo);
    event Voted(address indexed projectOwner, address indexed voter, bool inSupport);
    event VotingFinished(address indexed projectOwner, bool inSupport);
    event VotingRejected(address indexed projectOwner);

    struct Project {
        uint   yearReqFund;
        string urlInfo;
        uint   votingDeadline;
        uint   numberOfVotes;
        uint   yea;
        uint   nay;
        mapping (address => Vote) votes;
        mapping (uint => address) votesIter;
    }
    mapping (address => Project) public projects;

    function setDeploymentPriceYear(uint _price) public onlyOwner {
        deploymentPriceYear = _price;
    }

    function deployProject(uint _yearReqFund, string _urlInfo) public
        onlyTokenHolders enabledOrMigrationState {
        require(_yearReqFund > 0 && _yearReqFund <= balanceOf[this]);
        require(projects[msg.sender].yearReqFund == 0);
        transfer(this, deploymentPriceYear);
        projects[msg.sender].yearReqFund = _yearReqFund;
        projects[msg.sender].urlInfo = _urlInfo;
        projects[msg.sender].votingDeadline = now + 7 days;
        Deployed(msg.sender, _yearReqFund, _urlInfo);
    }
    
    function projectInfo(address _projectOwner) enabledOrMigrationState constant public 
        returns(uint _yearReqFund, string _urlInfo, uint _timeToFinish) {
        _yearReqFund = projects[_projectOwner].yearReqFund;
        _urlInfo = projects[_projectOwner].urlInfo;
        if (projects[_projectOwner].votingDeadline <= now) {
            _timeToFinish = 0;
        } else {
            _timeToFinish = projects[_projectOwner].votingDeadline - now;
        }
    }

    function vote(address _projectOwner, bool _inSupport) public
        onlyTokenHolders enabledOrMigrationState returns (uint voteId) {
        Project storage p = projects[_projectOwner];
        require(p.yearReqFund > 0);
        require(p.votes[msg.sender] == Vote.NoVote);
        require(p.votingDeadline > now);
        voteId = p.numberOfVotes++;
        p.votesIter[voteId] = msg.sender;
        if (_inSupport) {
            p.votes[msg.sender] = Vote.VoteYea;
        } else {
            p.votes[msg.sender] = Vote.VoteNay;
        }
        Voted(_projectOwner, msg.sender, _inSupport); 
        return voteId;
    }
    
    function rejectProject(address _projectOwner) public onlyOwner {
        require(projects[_projectOwner].yearReqFund > 0);
        delete projects[_projectOwner];
        VotingRejected(_projectOwner);
    }

    function finishVoting(address _projectOwner, uint _votesToProcess) public
        enabledOrMigrationState returns (bool _inSupport) {
        Project storage p = projects[_projectOwner];
        require(p.yearReqFund > 0);
        require(now >= p.votingDeadline && p.yearReqFund <= balanceOf[this]);

        while (_votesToProcess > 0 && p.numberOfVotes > 0) {
            address voter = p.votesIter[--p.numberOfVotes];
            Vote v = p.votes[voter];
            uint voteWeight = balanceOf[voter];
            if (v == Vote.VoteYea) {
                p.yea += voteWeight;
            } else if (v == Vote.VoteNay) {
                p.nay += voteWeight;
            }
            delete p.votesIter[p.numberOfVotes];
            delete p.votes[voter];
            --_votesToProcess;
        }
        if (p.numberOfVotes > 0) {
            _inSupport = false;
            return;
        }

        _inSupport = (p.yea > p.nay);

        uint yearReqFund = p.yearReqFund;
        delete projects[_projectOwner];

        if (_inSupport) {
            require(balanceOf[_projectOwner] + yearReqFund >= balanceOf[_projectOwner]); // overflow
            balanceOf[this] -= yearReqFund;
            balanceOf[_projectOwner] += yearReqFund;
            Transfer(this, _projectOwner, yearReqFund);
        }

        VotingFinished(_projectOwner, _inSupport);
    }
}
