pragma solidity ^0.4.11;

contract SendableToken
{// Abstract contract for transferable token under ERC20 Standard
 // https://github.com/ethereum/EIPs/issues/20
    // --------- Contract Data ------------
    address public              owner;      // Owner of contract
    
    uint  public                 totalSupply;// Total ammount of tokens
    mapping (address => uint256) balances;   // Balance for each account, always positive or zero
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;
    
    // ------------ Modifiers -----------
    modifier onlyOwner
        { require(msg.sender == owner); _; }
    
    function SendableToken(address _owner, uint _count)
    {// Constructor
        totalSupply = _count; 
        owner = _owner;
        balances[owner] = _count;
    }
    
    // ----------- Interface ----------------
    function totalSupply() constant returns(uint count) { return totalSupply; }
    function balanceOf(address _adr) constant returns(uint amount) { return balances[_adr]; }
    function allowance(address _owner, address _spender) constant returns (uint remaining)
        { return allowed[_owner][_spender]; }
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    function transfer(address _to, uint _amount) returns (bool success)
    {
        if (_amount == 0 || balances[msg.sender] < _amount)
            return false;
        balances[msg.sender] -= _amount;
        balances[_to] += _amount; // do not test for overflow because supply should be limited by uintMax and balance is never negative
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    function transferFrom(address _from, address _to, uint _amount) returns (bool success)
    {
        if (_amount == 0 || balances[msg.sender] < _amount  || allowed[_from][msg.sender] < _amount)
            return false;
        allowed[_from][msg.sender] -= _amount;
        balances[_from] -= _amount;
        balances[_to] += _amount; // do not test for overflow because supply should be limited by uintMax and balance is never negative
        Transfer(_from, _to, _amount);
        return true;
    }
    function approve(address _spender, uint _amount) returns (bool success) 
    {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
}

contract BasicCAP is SendableToken
{// Abstract contract for CAP token
     // --------- Contract Data ------------
    string public constant symbol = "CAP";
    string public constant name = "Capillar.io platform token";
    uint8 public constant decimals = 14; // TODO: Figure out decimals
    
    uint public         majorCAP;           // ammount of CAP tokens to qualify for Major status
    uint public         feeDenominator;     // denominator for counting fees for TRANS tokens transfers

    // ------------ Modifiers -----------
    modifier onlyMajor
    {// Check major status
        require(balances[msg.sender] >= majorCAP);
        _;
    }
    
    function BasicCAP() SendableToken(msg.sender, 100000000000)
    {// Constructor
        majorCAP = 1000000000;
        feeDenominator = 10000;
    }
    
    // ------ Interface -------------------
    event MajorQualiChanged(uint old, uint newcensus);
    event FeeChanged(uint old, uint newcensus);
    
    function isMajor(address _test) constant returns(bool) { return balances[_test] >= majorCAP; }
    function calculateTransferFee(uint _amount) constant returns(uint fee)
    {// Calculating fee for ammount of TRANS tokens
        fee = _amount / feeDenominator;
        fee = fee == 0 ? 1 : fee; // realisation for fee = max (1, fee)
    }
    
    function setMajorQuali(uint _census) onlyOwner
    {// Set cap for Major status
    // TODO: Make this function call require consensus of CAP holders
        require(_census != majorCAP && _census < totalSupply && _census > 0);
        uint oldCensus = majorCAP;
        majorCAP = _census;
        MajorQualiChanged(oldCensus, majorCAP);
    }
    function setFee(uint _denominator) onlyOwner
    {// Set fee rate
    // TODO: Make this function call require consensus of CAP holders
        require(_denominator != feeDenominator && _denominator > 0);
        uint old = feeDenominator;
        feeDenominator = _denominator;
        FeeChanged(old, _denominator);
    }
}

// =============== Basic Trans token ===========
contract TransToken
{
    string public       symbol;   // Basic parameters for Token
    string public       name;
    uint8 public        decimals;
    uint public         totalSupply;    // Total ammount of tokens (adjusted automatically)
    mapping (address => uint256) public balances;  // Balance for each account
    
    Cappilario          creator;    // Parent contract of Capillario platform
    uint                tokenID;    // ID of token Application
    
    uint public         maxSupply;  // Max ammount of tokens (limits totalSupply)
    
    address public      owner;      // Carrier - owner of token
    bytes32 public      carrierData;// Carrier capacity description
    
    function TransToken(uint _id, address _major, address _carrier, bytes32 data, uint _supply,
                        uint _reward, string _name, string _symbol, uint8 _decimals)
    {// Constructor
        require(_reward < _supply);   // Cannot give all or more than you have
        creator = Cappilario(msg.sender);
        tokenID = _id;
        owner = _carrier;
        carrierData =  data;
        maxSupply = _supply;
        totalSupply = _reward;
        balances[_major] = _reward;
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
    }
    function () { throw; } // fallback function
    
    // TODO: add contract closure flag and functions to kill contract
    /*function killToken() onlyCreator
    {// TODO: Conditions ?
        selfdestruct(creator);
    }*/
    
    // ------------ Modifiers ------------
    modifier onlyOwner // Check carrier status
        {  require(msg.sender == owner); _;   }
    modifier onlyCreator // Check admin status
        {  require(Cappilario(msg.sender) == creator);     _;  }
    
    // ---------- Events ------------------
    event Transfer(address indexed _from, address indexed _to, uint _value, uint _fee);
    event TokenChanged(bytes32 _newData, uint _newSupply);
    
    // -------- Const Interface ----------
    function totalSupply() constant returns(uint count) { return totalSupply; }
    function balanceOf(address _adr) constant returns(uint amount) { return balances[_adr]; }
    
    // ------ Interface -------------------
   function transferC(address _to, uint _amount) onlyCreator returns (bool success)
    {// transfer without fee if sender is creator
        if (_amount == 0 || balances[msg.sender] < _amount)
            return false;
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount, 0);
        return true;
    }
    
    function transfer(address _to, uint _amount) returns (bool success)
    {// fee is paid by sender
        if (_amount == 0)
            return false;
        uint amount = _amount + creator.calculateTransferFee(_amount);
        if (amount <= _amount || balances[msg.sender] < amount)
            return false;
            
        balances[msg.sender] -= amount;
        if (balances[msg.sender] < creator.calculateTransferFee(0))
        {// if balance is too low to make transactions - take remainings as additional fee
            amount += balances[msg.sender];
            balances[msg.sender] = 0;
        }
        balances[creator] += amount - _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount, amount - _amount);
        return true;
    }
    
    function updateCarrierData(bytes32 _newData, uint _newSupply) onlyOwner
    {// Changing carrier data and token limit
    // TODO: add fee? and auditors approval
        require(carrierData != _newData && maxSupply != _newSupply);
        carrierData = _newData;
        maxSupply = _newSupply;
        TokenChanged(_newData, _newSupply);
    }
}

// =============== Contract for a single Shipment ===========
contract Shipment
{
    enum ShipmentStatus // Data type for shipment tracking
    { 
        created,        // Shipment created
        ready,          // Sender is ready for cargo transfer
        started,        // Carrier got cargo from sender and started shipment
        finished,       // Carrier shipped cargo to destination and ready for cargo transfer
        confirmed       // Reciever got cargo from carrier
    }
    // uint public creationTime = now;     // Time of creation TODO: add time restrictions
    
    ShipmentStatus public status = ShipmentStatus.created;  // Shipment status
    
    CarrierToken public creator;    // TRANS-contract responsible for shipment
    uint    public      servID;     // ID of service in TRANS-contract
    address public      carrier;    // Carrier for this shipment (can be different from owner of TRANS contract)
    address public      owner;      // customer of shipment service - he is the boss
    address public      sender;     // Person responsible for giving cargo to carrier
    address public      reciever;   // Person responsible for getting cargo from carrier
    
    bytes32 public      serviceData;// Service description
    bytes32 public      cargoData;  // Cargo description
    
    function Shipment(uint _id, address _carrier, address _owner, address _sender, address _reciever,
                        bytes32 _service, bytes32 _cargo)
    {
        creator = CarrierToken(msg.sender);
        servID = _id;
        carrier = _carrier;
        owner = _owner;
        sender = _sender;
        reciever = _reciever;
        serviceData = _service;
        cargoData = _cargo;
    }
    function () { throw; } // fallback function
    
    // ------------ Modifiers ------------
    modifier onlyCreator()
        { require(creator == msg.sender); _; }
    modifier onlyOwner()
        { require(owner == msg.sender); _; }
    modifier onlyCarrier()
        { require(carrier == msg.sender); _; }
    modifier onlySender()
        { require(sender == msg.sender); _; }
    modifier onlyReciever()
       { require(reciever == msg.sender); _; }
    
    // --------------- Events ---------------
    event StatusChanged(ShipmentStatus _status);
    event OwnerChanged(address indexed _newOwner);
    event CarrierChanged(address indexed _newCarrier);
    event SenderChanged(address indexed _newSender);
    event RecieverChanged(address indexed _newReciever);
    
    function isCompleted() constant returns(bool indeed)
        { return status == ShipmentStatus.confirmed; }
    
    // -------- Status changing functions ---------
    function CargoReady() onlySender
    {
        require(status == ShipmentStatus.created);
        status = ShipmentStatus.ready;
        StatusChanged(status);
    }
    function StartShipping() onlyCarrier
    {
        require(status == ShipmentStatus.ready);
        status = ShipmentStatus.started;
        StatusChanged(status);
    }
    function FinishShipping() onlyCarrier
    {
        require(status == ShipmentStatus.started);
        status = ShipmentStatus.finished;
        StatusChanged(status);
    }
    function ConfirmShipment() onlyReciever
    {
        require(status == ShipmentStatus.finished);
        status = ShipmentStatus.confirmed;
        StatusChanged(status);
    }
    
    // --------- Interface --------------------
    function setOwner(address _newOwner) onlyOwner 
    {// Change carrier - only before shipment started!
        require(owner != _newOwner);
        owner = _newOwner;
        OwnerChanged(_newOwner);
        // TODO: Figure out who gets what if shipment is canceled. 
        // If owner gets tokens, then it is a way to transfer with no fee
    }
    function setCarrier(address _newCarrier) onlyCreator // TODO: add procedure in CarrierToken
    {// Change carrier - only before shipment started!
        require(_newCarrier != carrier);
        require(status == ShipmentStatus.created || status == ShipmentStatus.ready);
        carrier = _newCarrier;
        CarrierChanged(_newCarrier);
    }
    function setSender(address _newSender) onlyOwner
    {// Changing sender available before sending cargo
        require(status == ShipmentStatus.created);
        require(_newSender != sender);
        sender = _newSender;
        SenderChanged(_newSender);
    }
    function setReciever(address _newRecieverr) onlyOwner
    {// Changing reciever available before recieving cargo
        require(status != ShipmentStatus.confirmed);
        require(_newRecieverr != reciever);
        reciever = _newRecieverr;
        SenderChanged(_newRecieverr);
    }
    function kill() onlyCreator
        { selfdestruct(creator); }
}

// =============== Contract for a multimodal Shipment ===========
contract MultiShipment
{
    // TODO: not implemented yet
}

// ========== Contract for carriers services ================================
contract CarrierToken is TransToken
{
    enum ServiceStatus // Data type for service tracking
    { 
        open,       // Service created
        reserved,   // customer reserved service and transfered tokens
        started     // customer initiated service execution
    }
    
    struct Service
    {// Structure for keepnig service offers
        ServiceStatus   status;         // status descriptor
        address         carrier;        // responsible for delivering service
        address         customer;          // owner of TRANS tokens
        bytes32         data;           // service description
        uint            maxPrice;       // declared max price for serivice
        uint            price;          // current price
        Shipment        shipContract;   // Shipment contract
        bool            isService;      // service exists flag
    }
    
    // --------- Contract Data ------------
    uint public     serviceSupply = 0;  // Sum of all serviceMaxPrices
    uint            serviceIDBase = 0;  // Counter for unique service ids
    mapping(uint => Service) public services;   // services data
    
    // ------------ Modifiers ------------
    modifier isActiveService(uint _servID)
        {  require(services[_servID].isService);    _;  }
    
    function CarrierToken(uint _id, address _major, address _carrier, bytes32 _data, uint _supply,
                        uint _reward, string _name, string _symbol, uint8 _decimals) 
            TransToken(_id, _major, _carrier, _data, _supply, _reward, _name, _symbol, _decimals)
        {/* Constructor*/ }
    function () { throw; } // fallback function
    
    // ---------- Events ------------------
    event ServiceAdded(uint indexed _servID, uint _price, bytes32 _data);
    event ServiceCarrierChanged(uint indexed _servID, address indexed _newCarrier);
    event ServicePriceChanged(uint indexed _servID, uint indexed _newPrice);
    event ServiceReserved(uint indexed _servID, address indexed _customer);
    event ServiceStarted(uint indexed _servID, Shipment _ship);
    event ServiceTerminated(uint indexed _servID);
    
    // ------ Interface -------------------
    function addService(bytes32 _data, uint _price) onlyOwner returns(uint servID)
    {// Create new service
        // TODO: add service validation by platform
        require(_price > 0);
        require(serviceSupply + _price > serviceSupply);
        serviceSupply += _price;
        require(serviceSupply <= maxSupply);
        
        services[serviceIDBase+1] = Service(ServiceStatus.open, owner, 0x0, _data, _price,  _price, Shipment(0x0), true);
        serviceIDBase++; 
        assert(serviceIDBase > 0); // TODO: handle overflow or remove assert
        
        if (serviceSupply > totalSupply)
        {
            balances[owner] += serviceSupply - totalSupply;
            totalSupply = serviceSupply;
            // TODO: add fee?
        }
        
        ServiceAdded(serviceIDBase, _price, _data);
        return serviceIDBase;
    }
    function serviceSetPrice(uint _servID, uint _newPrice) isActiveService(_servID)
    {// Change price for open service
        Service storage serv = services[_servID];
        require(serv.price != _newPrice);
        require(serv.carrier == msg.sender);
        require(_newPrice <= serv.maxPrice);
        require(serv.status == ServiceStatus.open);
        
        serv.price = _newPrice;
        ServicePriceChanged(_servID, _newPrice);
    }
    function serviceSetCarrier(uint _servID, address _newCarrier) onlyOwner isActiveService(_servID)
    {// Change carrier for non-started service
        Service storage serv = services[_servID];
        require(serv.carrier != _newCarrier);
        require(serv.status == ServiceStatus.open || serv.status == ServiceStatus.reserved);
        
        serv.carrier = _newCarrier;
        ServiceCarrierChanged(_servID, _newCarrier);
    }
    function reserveService(uint _servID) isActiveService (_servID)
    {// Reserve service using TRANS tokens
        Service storage serv = services[_servID];
        require(serv.status == ServiceStatus.open);
        require(balances[msg.sender] >= serv.price);
        
        balances[msg.sender] -= serv.price; // TODO: check if remaining balance is too small
        serv.status = ServiceStatus.reserved;
        serv.customer = msg.sender;
        ServiceReserved(_servID, msg.sender);
    }
    function startShipment(uint _servID, bytes32 _cargo, address _sender, address _reciever) isActiveService (_servID)
    {// Initiate Shipment procedure
        Service storage serv = services[_servID];
        require(serv.status == ServiceStatus.reserved);

        serv.shipContract = new Shipment(_servID, serv.carrier, serv.customer, _sender, _reciever, serv.data, _cargo);
        ServiceStarted(_servID, serv.shipContract);
    }
    function terminateService(uint _servID) onlyOwner isActiveService (_servID)
    {// Terminate finished service to free up token limit for next services
        // TODO: termmination checks and consequences
        Service storage serv = services[_servID];
        require(serv.status == ServiceStatus.started);
        require(serv.shipContract.isCompleted());
        
        serv.shipContract.kill();
        totalSupply -= serv.price;
        serviceSupply -= serv.maxPrice;
        delete services[_servID];
        ServiceTerminated(_servID);
    }
}

//================= CAP ICO contract =======================
// Provides full ERC20 functionality: https://github.com/ethereum/EIPs/issues/20
// CAP_ICO tokens can be exchanged for CAP tokens when Capillar.io platform is realesed
contract CAP_ICO
{// TODO: use #import statement instead of dummy
    function balanceOf(address _account) constant returns(uint value) 
        { return 0; }
    function burnBalance(address _account) returns(uint value)
        { return 0;   }
}

// =============== Main contract of Cappilar.io platform ===========
contract Cappilario is BasicCAP
{
    // ---------- Data Structure -----------
    struct TransApplication
    {// Заявка перевозчика
        address         carrier;        // Carrier-owner of transport units
        bytes32         data;           // Description of transport units
        uint            supply;         // Ammount of TRANS tokens needed
        uint            reward;         // Ammount of tokens as a premium for approval
        
        // bool isValid;    // TODO: add auditors to validate data
        
        address         major;
        CarrierToken    tokenContract;   // address for token contract
        bool            capApproved;    // Flag of major CAP holder approval
        
        bool            isCreated;      // Flag prevents from creating two contracts with one application
        bool            isApplication;  // Flag to distinguish null element of mapping from deliberate 0 element
    }
   
    // --------- Contract Data -----------
    uint appIDBase = 0;                 // TODO: check for overflow
    mapping(uint => TransApplication) public applications; // Applications to create new TRANS token
    
    CAP_ICO             ico;        // Address for ICO contract
    
    // ------------ Modifiers ------------
    modifier isActiveApplication(uint _appID)
        {  require(applications[_appID].isApplication && !applications[_appID].isCreated);   _;   }
    modifier onlyTrans(uint _appID) // sender must be TRANS contract
        {  require(applications[_appID].tokenContract == msg.sender);   _;  }
    
    function Cappilario() {    }    // constructor see BasicCAP
    function () { throw; }          // fallback function
    
    // ----------------- ICO tokens transfer interface ----------------------------------
    function setICOAddress(address _ico) onlyOwner
    {// Determine address to transfer tokens from
        ico = CAP_ICO(_ico);
    }
    function withdrawICO() returns(uint ammount)
    {// Transfering all tokens for msg.sender from ICO contract
        ammount = ico.balanceOf(msg.sender);
        require(ammount > 0);
        require(ammount <= balances[owner]);
        require(ammount == ico.burnBalance(msg.sender)); // Burning ICO tokens
        
        balances[owner] -= ammount;
        balances[msg.sender] += ammount; // TODO: test overflow
        Transfer(owner, msg.sender, ammount);
    }
    
    // ---------------- Application for TRANS token Interface ------------------------
    function applicationRewardInfo(uint appID) constant isActiveApplication(appID) returns(uint supply, uint reward)
    {// Access to reward info
        supply = applications[appID].supply; reward = applications[appID].reward;
    }
    
    event ApplicationCreated(uint indexed _appID, address indexed _carrier, uint _supply, uint _reward, bytes32 _data);
    event ApplicationApproved(uint indexed _appID, address indexed _major);
    event ApplicationRewardChanged(uint indexed _appID, uint _oldReward, uint _newReward);
    event ApplicationCanceled(uint indexed _appID);
    event TokenCreated(address indexed _token, address indexed _carrier, uint indexed _appID);
    
    function newApplication(bytes32 _data, uint _supply, uint _reward) returns (uint appID)
    {// Create application for TRANS contract creation for regular users
        // TODO: prevent application spam
        require(_supply > 0);
        
        applications[appIDBase+1] = TransApplication(msg.sender, _data, _supply,  _reward, 
                                                    0x0, CarrierToken(0x0), false, false, true);
        
        appIDBase++; 
        assert(appIDBase > 0); // TODO: handle overflow or remove assert
        ApplicationCreated(appIDBase, msg.sender, _supply, _reward, _data);
        return appIDBase;
    }
    
    function newApplicationM(bytes32 _data, uint _supply) onlyMajor returns (uint appID)
    {// Special option for major CAP holder when creating an application - approve it and set fee to 0
        require(_supply > 0);
        
        applications[appIDBase+1] = TransApplication(msg.sender, _data, _supply,  0, 
                                                    msg.sender, CarrierToken(0x0), true, false, true);
        appIDBase++;
        assert(appIDBase > 0); // TODO: handle overflow or remove assert
        ApplicationCreated(appIDBase, msg.sender, _supply, 0, _data);
        ApplicationApproved(appIDBase, msg.sender);
        return appIDBase;
    }
    
    function changeApplicationReward(uint _appID, uint _newReward) isActiveApplication (_appID)
    {// carrier can modify reward for non-approved application
        TransApplication storage appl = applications[_appID];
        require(msg.sender == appl.carrier);
        require(appl.capApproved == false); // no use in changing reward for approved contract
        require(_newReward < appl.supply && _newReward != appl.reward);
        uint old = appl.reward;
        appl.reward = _newReward;
        ApplicationRewardChanged(_appID, old, _newReward);
    }
    
    function cancelApplication(uint _appID) isActiveApplication (_appID)
    {// carrier can modify reward for non-approved application
        TransApplication storage appl = applications[_appID];
        require(msg.sender == appl.carrier);

        appl.isApplication = false;
        delete applications[_appID];
        ApplicationCanceled(_appID);
    }
    
    function approveApplication(uint _appID) isActiveApplication (_appID) onlyMajor
    {// Approve application to get reward when contract is created
        require(applications[_appID].capApproved == false);
        applications[_appID].capApproved = true;
        applications[_appID].major = msg.sender;
        ApplicationApproved(appIDBase, msg.sender);
    }
    
    function createTrans(uint _appID, string _name, string _symbol, uint8 _decimals) 
                        isActiveApplication (_appID) returns(CarrierToken adr)
    {// Create TRANS token from approved application
        TransApplication storage appl = applications[_appID];
        
        require(appl.capApproved); // Make sure application is approved
        require(msg.sender == appl.carrier);
        
        adr = new CarrierToken(_appID, appl.major, msg.sender, appl.data, appl.supply, appl.reward, _name, _symbol, _decimals);
        appl.tokenContract = adr;
        appl.isCreated = true;
        
        TokenCreated(address(adr), msg.sender, _appID);
    }
}