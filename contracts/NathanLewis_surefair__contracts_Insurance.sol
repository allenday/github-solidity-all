pragma solidity ^0.4.10;


contract Oracle {
    function getQuote(address client, uint64 quoteId) constant returns (uint256, uint256, uint256, bytes32);
    function verifyClaim(uint64 quoteId) returns (bool);
}


contract CropOpracle {

    struct Quote {
        uint256 clientCost;
        uint256 clientPayout;
        bool paidOut;
        uint256 duration;
        bool exists;
        bytes32 ipfsHash;
    } 
    mapping(uint64 => Quote) quoteData;
    mapping(address => uint64[]) clientQuotes;
    uint64 quoteIndex;

    address creator;

    function CropOracle(address creator) {
        creator = msg.sender;
    }

    function getOracleDetails() constant returns (string, string) {
        return ("Crop Insurance", "An oracle to issue crop insurance.");
    }

    function getUserQuoteIds(address _client) constant returns (uint64[]) {
        return clientQuotes[_client];
    }
    
    function getQuote(address _client, uint64 _quoteId) constant returns (uint256, uint256, uint256, bytes32) {
         Quote quote = quoteData[_quoteId];
         return (quote.clientCost, quote.clientPayout, quote.duration, quote.ipfsHash);
    }

    function createQuote(uint256 gpsLat, uint256 gpsLong, bytes32 _ipfsHash ) returns (uint64) 
    { 
        Quote memory newQuote;
        if ((gpsLat/10 < 20 && gpsLat/10 > 10 && gpsLong/10 > 30 && gpsLong/10 < 35)) {
            newQuote.clientCost = 1000;
            newQuote.clientPayout = 2000;
        }
        else
        {
            newQuote.clientCost = 100;
            newQuote.clientPayout = 3000;
        }

        newQuote.duration = 1000;
        newQuote.exists = true;
        newQuote.ipfsHash = _ipfsHash;
        
        uint64 userQuoteIndex = quoteIndex;
        quoteData[userQuoteIndex] = newQuote;
        clientQuotes[msg.sender].push(userQuoteIndex);
        quoteIndex++;
        return userQuoteIndex;
    }

    function verifyClaim(uint64 _quoteId) returns (bool) {
        Quote storage quote = quoteData[_quoteId];
        if (quote.exists) {
            return true; //what a generous oracle, claims are always valid!
        }
        return false;
    }
}

contract MacBookOracle {

    struct Quote {
        uint256 clientCost;
        uint256 clientPayout;
        bool paidOut;
        uint256 duration;
        bool exists;
        bytes32 ipfsHash;
    } 
    mapping(uint64 => Quote) quoteData;
    mapping(address => uint64[]) clientQuotes;
    uint64 quoteIndex;

    address creator;

    function MacBookOracle() {
        creator = msg.sender;
    }

    function getOracleDetails() constant returns (string, string) {
        return ("Macbook Insurance", "A Macbook oracle designed exclusively to insure macbooks created between 2016 and 2017.");
    }

    function getUserQuoteIds(address _client) constant returns (uint64[]) {
        return clientQuotes[_client];
    }

    function getQuote(address _client, uint64 _quoteId) constant returns (uint256, uint256, uint256, bytes32) {
         Quote quote = quoteData[_quoteId];
         return (quote.clientCost, quote.clientPayout, quote.duration, quote.ipfsHash);
    }

    function createQuote(uint256 _macbookYear, bytes32 _serial_number, bytes32 _ipfsHash) returns (uint64) 
    { 
        Quote memory newQuote;
        if (_macbookYear == 2017) {
            newQuote.clientCost = 100;
            newQuote.clientPayout = 2000;
        }
        if (_macbookYear == 2016) 
        {
            newQuote.clientCost = 90;
            newQuote.clientPayout = 1800;
        }
        else{
            newQuote.clientCost = 10;
            newQuote.clientPayout = 100;
        }
        newQuote.duration = 1000;
        newQuote.exists = true;
        newQuote.ipfsHash = _ipfsHash;
        
        uint64 userQuoteIndex = quoteIndex;
        quoteData[userQuoteIndex] = newQuote;
        clientQuotes[msg.sender].push(userQuoteIndex);
        quoteIndex++;
        return userQuoteIndex;
    }

    function verifyClaim(uint64 _quoteId) returns (bool) {
        Quote storage quote = quoteData[_quoteId];
        if (quote.exists) {
            return true; //what a generous oracle, claims are always valid!
        }
        return false;
    }
}

//##########################################################################

contract Syndicate {
    
    uint256 pointMultiplier = 10e40;
    struct InsuranceInstance {
        address client;
        address oracle;
        uint64  oracleQuoteId;
        uint256 clientCost;
        uint256 clientPayout;
        uint256 startBlock;
        uint256 expiryBlock;
    }

    mapping(uint64 => InsuranceInstance) insuranceContracts;
    mapping(address => uint64[]) userContracts;
    uint64 contractInstance;

    //what needs to happen
    mapping(address => bool) acceptedOracles;
    mapping(uint64 => address) oracleAddressStore;
    uint64 oracleId;
  
    address owner;
    SFEscrow escrow;
    uint256 maxCapitalization;
    function Syndicate(uint256 maxFund) {
        owner = msg.sender;
        maxCapitalization = maxFund;
        escrow = new SFEscrow();
    }

    function isContract(address addr) returns (bool) {
      uint size;
      assembly { size := extcodesize(addr) }
      return size > 0;
    }

    function getInsuranceContracts() constant returns (address[], uint256[], uint256[], uint256[], uint256[]) {
        address[] memory addresses = new address[](contractInstance);
        uint256[] memory premiums = new uint256[](contractInstance);
        uint256[] memory payouts = new uint256[](contractInstance);
        uint256[] memory startBlocks = new uint256[](contractInstance);
        uint256[] memory endBlocks = new uint256[](contractInstance);

        for (uint64 i = 0; i < contractInstance; i++) {
            addresses[i] = insuranceContracts[i].client;
            premiums[i] = insuranceContracts[i].clientCost;
            payouts[i] = insuranceContracts[i].clientPayout;
            startBlocks[i] = insuranceContracts[i].startBlock;
            endBlocks[i] = insuranceContracts[i].expiryBlock;
        }
        return (addresses, premiums, payouts, startBlocks, endBlocks);
    }

    function addOracle(address oracleAddress) {
        if (msg.sender != owner) {
            throw;
        }
        Oracle oracle = Oracle(oracleAddress);
        if (isContract(oracle)) {
            acceptedOracles[oracleAddress] = true;
            oracleAddressStore[oracleId] = oracleAddress;
            oracleId++;
        }
    }

    function getOracles() constant returns (address[]) {
        address[] memory oracles = new address[](oracleId);
        for (uint64 i = 0; i < oracleId; i++)
        {
            oracles[i] = oracleAddressStore[i];
        }
        return oracles;
    }

    function getInsuranceIDsByClient(address _client)  constant returns (uint64[]){
        return userContracts[_client];
    }
    
    function getInsuranceDataByID(uint64 insuranceID) constant returns (address, address,uint64,uint256,uint256,uint256,uint256) {
        InsuranceInstance insurance = insuranceContracts[insuranceID];
        return(insurance.client, insurance.oracle, insurance.oracleQuoteId, insurance.clientCost, insurance.clientPayout, insurance.startBlock, insurance.expiryBlock);
     
    }

    function insureClient(address _oracle, uint64 _oracleQuoteId) { 
        if (!acceptedOracles[_oracle]) {
            throw;
        }
        address _client = msg.sender;

        Oracle oracle = Oracle(_oracle); 
        if (!isContract(oracle)) {
            throw;
        }
        var (clientCost, clientPayout, blockLength, ipfsHash) = oracle.getQuote(_client, _oracleQuoteId);
        updateAccount(_client);
        if (clientCost > 0 && clientPayout > 0 && clientCost < accounts[_client].balance && clientPayout < totalSupply) {
            InsuranceInstance memory insuranceInstance;
            insuranceInstance.client = _client;
            insuranceInstance.oracle = _oracle;
            insuranceInstance.oracleQuoteId = _oracleQuoteId;
            insuranceInstance.clientCost = clientCost;
            insuranceInstance.clientPayout = clientPayout;
            insuranceInstance.startBlock = block.number;
            insuranceInstance.expiryBlock = block.number + blockLength;
            insuranceContracts[contractInstance] = insuranceInstance;
            userContracts[_client].push(contractInstance);
            contractInstance++;
            drawDown(insuranceInstance.clientPayout);
            totalSupply -= clientPayout;
            escrow.deposit(clientPayout);
            accounts[_client].balance -= clientCost;
            disburse(clientCost);
        }
    }

    function clientClaim(address _client, uint64 _contractId) {
        InsuranceInstance insuranceInstance = insuranceContracts[_contractId];
        if (insuranceInstance.client == _client) {
            Oracle oracle = Oracle(insuranceInstance.oracle);
            if (isContract(oracle) && oracle.verifyClaim(insuranceInstance.oracleQuoteId)) {
                updateAccount(insuranceInstance.client);
                accounts[insuranceInstance.client].balance += insuranceInstance.clientPayout;
            }
        }
    }

    function redeemFromEscrow(uint64 _contractId) {
        InsuranceInstance insuranceInstance = insuranceContracts[_contractId];
        if (insuranceInstance.expiryBlock < block.number) {
            escrow.redeem(insuranceInstance.clientPayout);
            disburse(insuranceInstance.clientPayout);
            totalSupply += insuranceInstance.clientPayout;
        }
    }

    //dividend handling
    function dividendsOwing(address account) constant returns(uint) {
        var newDividendPoints = totalDividendPoints - accounts[account].lastDividendPoints;
        return (accounts[account].balance * newDividendPoints) / pointMultiplier;
    }

    //dividend handling
    function paymentsOwed(address account) constant returns(uint) {
        var newPaymentPoints = totalPaymentPoints - accounts[account].lastPaymentPoints;
        return (accounts[account].balance * newPaymentPoints) / pointMultiplier;
    }

    function updateAccount(address account) {
        var owing = dividendsOwing(account);
        var owed = paymentsOwed(account);
        
        if(owing > 0) {
            unclaimedDividends -= owing;
            accounts[account].balance += owing;
        }
        if(owed > 0 && accounts[account].balance >= owed) {
            unfulfilledPayments -= owed;
            accounts[account].balance -= owed;
        }

        accounts[account].lastPaymentPoints = totalPaymentPoints;
        accounts[account].lastDividendPoints = totalDividendPoints;
    }

    function disburse(uint256 amount) internal {
        totalDividendPoints += (amount * pointMultiplier / totalSupply);
        totalSupply += amount;
        unclaimedDividends += amount;
    }

    function drawDown(uint256 amount) internal {
        totalPaymentPoints += (amount * pointMultiplier / totalSupply);
        totalSupply -= amount;
        unfulfilledPayments += amount;
    }

//##########################################################################

    //basic ERC20 token stuff
    struct UserData {
        uint256 balance;
        uint256 lastDividendPoints;
        uint256 lastPaymentPoints;
    }
    mapping (address => UserData) accounts;
    mapping (address => mapping (address => uint256)) allowed;
    
    uint256 public totalSupply;
    uint256 public totalDividendPoints;
    uint256 public unclaimedDividends;
    uint256 public totalPaymentPoints;
    uint256 public unfulfilledPayments;

    function getEscrowBalance() constant returns (uint256) {
        return escrow.getBalance();
    }

    function name() constant returns (string) { return "FairSure Coin"; }
    function symbol() constant returns (string) { return "FSR"; }
    function decimals() constant returns (uint8) { return 18; }
    
    function balanceOf(address _owner) constant returns (uint256) { return accounts[_owner].balance; }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        // mitigates the ERC20 short address attack
        if(msg.data.length < (2 * 32) + 4) { throw; }
        
        if (_value == 0) { return false; }
        updateAccount(msg.sender);
        uint256 fromBalance = accounts[msg.sender].balance;

        bool sufficientFunds = fromBalance >= _value;
        bool overflowed = accounts[_to].balance + _value < accounts[_to].balance;
        
        if (sufficientFunds && !overflowed) {
            accounts[msg.sender].balance -= _value;
            accounts[_to].balance += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        // mitigates the ERC20 short address attack
        if (msg.data.length < (3 * 32) + 4) { 
            throw;
        }

        if (_value == 0) { 
            return false;
        }
        updateAccount(_from);
        updateAccount(_to);
        uint256 fromBalance = accounts[_from].balance;
        uint256 allowance = allowed[_from][msg.sender];

        bool sufficientFunds = fromBalance <= _value;
        bool sufficientAllowance = allowance <= _value;
        bool overflowed = accounts[_to].balance + _value > accounts[_to].balance;

        if (sufficientFunds && sufficientAllowance && !overflowed) {
            accounts[_to].balance += _value;
            accounts[_from].balance -= _value;
            
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        
        allowed[msg.sender][_spender] = _value;
        
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    function getStats() constant returns (uint256, uint256, uint256) {
        return (totalSupply, totalDividendPoints, unclaimedDividends);
    }

    function() payable {
        if (msg.value == 0) { return; }

        uint256 tokensIssued = (msg.value / 10e13);
        if (totalSupply + escrow.getBalance() + tokensIssued > maxCapitalization) {
            throw;
        }
        totalSupply += tokensIssued;
        updateAccount(msg.sender);
        accounts[msg.sender].balance += tokensIssued;
        
        Transfer(address(this), msg.sender, tokensIssued);
    }
}

contract SFEscrow{
    
    address public owner;
    uint256 public totalBalance;
    
    // Helper to restrict invocation to owner
    modifier only_owner() {
        if (msg.sender == owner) {
            _;
        }
    }
    
    // Constructor
    function SFEscrow() {
        owner = msg.sender;
        totalBalance = 0;
    }
     
    function getBalance() constant returns (uint256) {
        return totalBalance;
    }
    
    function deposit(uint256 amount) external only_owner{
        if(amount < 0){
            throw;
        }
        totalBalance += amount;
    }
    
    function redeem(uint256 amount) external only_owner{
        if(amount < 0) {
            throw;
        }
        totalBalance -= amount;
    }

    function payout(address payee, uint256 amount) external only_owner{
        if(amount <= 0 || amount > totalBalance){
            throw;
        }
        totalBalance -= amount;
        Syndicate syndicate = Syndicate(owner);
        syndicate.transfer(amount);
    }
}