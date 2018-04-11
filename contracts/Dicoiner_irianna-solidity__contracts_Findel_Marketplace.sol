pragma solidity ^0.4.15;

import './Gateway.sol';

contract FincontractMarketplace {
    
  function FincontractMarketplace () { }
    
    
  /***** GLOBAL CONSTANTS *****/
    
  // Number of supported currencies
  uint CURRENCIES = 6;
    
  // For modeling 'immediate' execution: At(t0) = Timebound ( t0-delta/2, t0+delta/2 )
  uint DELTA = 30 seconds;
    
  // Upper bound on fincontracts validity time
  uint EXPIRATION = 1 years;
    
  // Gateway value must be more recent than this
  uint FRESHNESS = 60 seconds;
    
    
  /***** DATA TYPES *****/
    
  // SCALE and TIMEBOUND are modelled as fields of other Primitives
  enum Primitive { ZERO, ONE, GIVE, AND, OR, SCALEOBS, IF }
    
  // NONE must be last in enum due to how register() works.
  enum Currency { USD, EUR, GBP, JPY, CNY, SGD, NONE }
    
  /*
    Description is a recursive data structure reflecting all right and obligations.
    Real-world analogy: a contract template with parties to be written in.
    In many cases, some fields are left with defalut values (0x0, 1, etc).
    */
  struct Description {
    Primitive prim;     // what this node does
    Currency curr;      // currency (valid only for ONE)
    bytes32 dscId_1;    // 1st child Description
    bytes32 dscId_2;    // 2nd child Description
    int scaleCoeff;     // scaling coefficient
    address gateway;    // address of external gateway contract
    uint begin;         // can't be executed before this time
    uint end;           // can't be executed after this time
  }
    
  // Right and obligations are reflected in the underlying Description.
  struct Fincontract {
    address issuer;         // creator of fincontract
    address owner;          // can ecexute and transfer ownership
    bytes32 dscId;          // description id
    address proposedOwner;  // new owner (proposed by current owner)
  }
    
  // A User has an array of balances corresponding to currencies.
  struct User {
    bool registered;
    int[] balance;
  }
    
  mapping (bytes32 => Description) descriptions;
  mapping (bytes32 => Fincontract) fincontracts;
  mapping (address => User) users;
    
  // Event is how a user knows which new fincontracts it owns after execution.
  event PrimitiveStoredAt(bytes32 id);

  event Registered(address user);
  event CreatedBy(address user, bytes32 fctId);
  event Owned(address newOwner, bytes32 fctId);
  event IssuedFor(address proposedOwner, bytes32 fctId);
  event Executed(bytes32 fctId);
  event Deleted(bytes32 fctId);
    
    
  /***** HELPER FUNCTIONS *****/
    
  // Registering an address means creating an zero array of proper length.
  function register() {
    require(!isRegistered());
    User memory newUser;
    newUser.balance = new int[](CURRENCIES);
    for (uint8 i = 0; i < CURRENCIES; i++) {
       newUser.balance[i] = 0;
    }
    users[msg.sender] = newUser;
    users[msg.sender].registered = true;
     Registered(msg.sender);
  }

  function isRegistered() constant returns (bool registered) { 
     return users[msg.sender].registered; 
  }
    
  modifier onlyRegistered() { 
     require(users[msg.sender].registered);
     _; 
  }
 
  modifier onlyOwner(bytes32 fctId) { 
    require(fincontracts[fctId].owner == msg.sender);
    _; 
  }
    
  /*
    Store a fincontract description in mapping.
    Id is NOT randomized (determined only by description fields).
   */
   function storeWithId(Description dsc) internal returns (bytes32 dscId) {
      var id = keccak256(dsc.prim, dsc.curr, dsc.dscId_1, dsc.dscId_2, dsc.scaleCoeff, dsc.gateway, dsc.begin, dsc.end);
      descriptions[id] = dsc;
      return id;
   }
    
   function getBalance(address user) onlyRegistered internal constant returns (int[]) { 
       return users[user].balance; 
   }

   function getMyBalance() constant returns (int[]) { 
       return getBalance(msg.sender); 
   }
    
    function getDescriptionInfo(bytes32 dscId) constant returns (Primitive prim, Currency curr, bytes32 dscId_1, bytes32 dscId_2, 
    int coeff, address gateway, uint begin, uint end) {
       var dsc = descriptions[dscId];
       return (dsc.prim, dsc.curr, dsc.dscId_1, dsc.dscId_2, dsc.scaleCoeff, dsc.gateway, dsc.begin, dsc.end);
    }
    
    function getFincontractInfo(bytes32 fctId) constant returns (address issuer, address owner, address proposedOwner, bytes32 dscId) {
       var fct = fincontracts[fctId];
       return (fct.issuer, fct.owner, fct.proposedOwner, fct.dscId);
    }
    
    //function getTimestamp() constant returns (uint256 timestamp) { return block.timestamp; }

    /****** DESCRIPTIONS *****/
    
    // Generic constructor for Description
    function GenericDescription(Primitive _prim, Currency _curr, bytes32 _dscId_1, bytes32 _dscId_2,
      int _scaleCoeff, address _gateway, uint _begin, uint _end) 
      internal returns (bytes32) {
        bytes32 id = storeWithId(Description({
            prim: _prim,
            curr: _curr,
            dscId_1: _dscId_1,
            dscId_2: _dscId_2,
            scaleCoeff: _scaleCoeff,
            gateway: _gateway,
            begin: _begin,
            end: _end
        }));
       PrimitiveStoredAt(id);
       return id;
    }
    
    // ZERO: no right, no obligations
    function Zero() returns (bytes32 dcsId) {
       return GenericDescription(Primitive.ZERO, Currency.NONE, 0x0, 0x0, 1, 0x0, 0, now + EXPIRATION);
    }
    
    // ONE: receive 1 unit of _curr Currency at execution
    function One(Currency _curr) returns (bytes32 dcsId) {
       return GenericDescription(Primitive.ONE, _curr, 0x0, 0x0, 1, 0x0, 0, now + EXPIRATION);
    }
    
    // GIVE: swap issuer and owner of _c1id
    function Give(bytes32 _dscId_1) returns (bytes32 dcsId) {
       return GenericDescription(Primitive.GIVE, Currency.NONE, _dscId_1, 0x0, 1, 0x0, 0, now + EXPIRATION);
    }
    
    // AND: execute _dscId_1 and then execute _dscId_2
    function And(bytes32 _dscId_1, bytes32 _dscId_2) returns (bytes32 dcsId) {
       return GenericDescription(Primitive.AND, Currency.NONE, _dscId_1, _dscId_2, 1, 0x0, 0, now + EXPIRATION);
    }
    
    // OR: owner can choose between executing _dscId_1 or _dscId_2
    function Or(bytes32 _dscId_1, bytes32 _dscId_2) returns (bytes32 dcsId) {
       return GenericDescription(Primitive.OR, Currency.NONE, _dscId_1, _dscId_2, 1, 0x0, 0, now + EXPIRATION);
    }
    
    // SCALE: multiply all payments by a constant factor
    function Scale(int _scaleCoeff, bytes32 _dscId) returns (bytes32 dcsId) {
       if (_scaleCoeff == 1) return _dscId;   // shortcut for efficiency
       var dsc = descriptions[_dscId];
       return GenericDescription(dsc.prim, dsc.curr, dsc.dscId_1, dsc.dscId_2, dsc.scaleCoeff * _scaleCoeff, dsc.gateway, dsc.begin, dsc.end);
    }
    
    // SCALEOBS: multiply all payment by an observable obtained from the gateway (resolved at execution)
    function ScaleObs(address _gateway, bytes32 _dscId) returns (bytes32 dcsId) {
       return GenericDescription(Primitive.SCALEOBS, Currency.NONE, _dscId, 0x0, 1, _gateway, 0, now + EXPIRATION);
    }
    
    // IF: if obsBool returns true, execute _dscId_1, else execute _dscId_2
    function If(address _gatewayBool, bytes32 _dscId_1, bytes32 _dscId_2) returns (bytes32 dcsId) {
       return GenericDescription(Primitive.IF, Currency.NONE, _dscId_1, _dscId_2, 1, _gatewayBool, 0, now + EXPIRATION);
    }
    
    // TIMEBOUND: can execute only if lowerBound <= now <= upperBound
    // Create NEW fc: same as cid, but with time bounds
    // No designated Timebound in Combinators enum
    function Timebound(uint lowerBound, uint upperBound, bytes32 _dscId_1) returns (bytes32 dcsId) {
        require(upperBound < (now + EXPIRATION));
        var dsc = descriptions[_dscId_1];
        return GenericDescription(dsc.prim, dsc.curr, dsc.dscId_1, dsc.dscId_2, dsc.scaleCoeff, dsc.gateway, lowerBound, upperBound);
    }
    
    // Three constructing function for convenience, all map to TIMEBOUND
    
    function At(uint exactTime, bytes32 _dscId_1) internal returns (bytes32 dcsId) {
       return Timebound(exactTime - DELTA/2, exactTime + DELTA/2, _dscId_1);
    }
    
    function Before(uint upperBound, bytes32 _dscId_1) internal returns (bytes32 dcsId) {
       return Timebound(0, upperBound, _dscId_1);
    }
    
    function After(uint lowerBound, bytes32 _dscId_1) internal returns (bytes32 dcsId) {
       return Timebound(lowerBound, now + EXPIRATION, _dscId_1);
    }
    
    
    /****** FINCONTRACTS ******/

    // Create new Fincontract of Description at _dscId with given parties.
    function createFincontractWithParties(address _issuer, address _owner, bytes32 _dscId) internal
    returns (bytes32 fctId) {
       Fincontract memory fct;
       fct.issuer = _issuer;
       fct.owner = _owner;
       fct.dscId = _dscId;
       fct.proposedOwner = _owner;
       bytes32 _fctId = keccak256(now, _issuer, _owner, _dscId);
       fincontracts[_fctId] = fct;
       CreatedBy(_issuer, _fctId);
       Owned(_owner, _fctId);
       return _fctId;
    }
    
    // Create a fincontract with oneself as issuer and owner.
    function createFincontract(bytes32 _dscId) returns (bytes32 fctId) {
       return createFincontractWithParties(msg.sender, msg.sender, _dscId);
    }
    
    // Until the proposed owner joins, old owner holds all rights and obligations.
    function issueFor(bytes32 _fctId, address _proposedOwner)
    onlyOwner(_fctId)
    onlyRegistered
    returns (bytes32 fctId) {
       fincontracts[_fctId].proposedOwner = _proposedOwner;
       IssuedFor(_proposedOwner, _fctId);
       return _fctId; // useless, kept for uniformity
    }
    
    // Declare oneself as owner. Can be called only as part of join().
    // Succeeds if proposedOwner is msg.sender or 0x0 (everyone).
    function own(bytes32 fctId) internal
    returns (bool success) {
       if (fincontracts[fctId].proposedOwner == msg.sender || fincontracts[fctId].proposedOwner == 0x0) {
          fincontracts[fctId].owner = msg.sender;
          fincontracts[fctId].proposedOwner = msg.sender;
          Owned(msg.sender, fctId);
          return true;
       }
       return false;
    }
    
    // Own and execute a fincontract. NB: Can't separate owning and executing!
    function join(bytes32 fctId)
    onlyRegistered
    returns (bool executedCompletely) {
       return own(fctId) ? execute(fctId) : false;
    }
    
    // This function ultimately makes the payment.
    function enforcePayment(address issuer, address owner, Currency currency, int amount) internal
    returns (bool success) {
       users[issuer].balance[uint(currency)] -= amount;
       users[owner].balance[uint(currency)] += amount;
       return true;
    }

    /*
    Internal function for recursive execution of a fincontract.
    Parties and accumulated scaling coefficient are passed as parameters.
    Returns true, if all subcontracts result in changing the parties' balances.
    Returns false, if some subcontracts result in some party owning a new fincontract.
    Note: this function knows nothing about the initial fincontract (i.f.)!
    I.f. is only an "entry point" to the DAG of descriptions. It gets deleted anyway by execute().
    */
    function executeRecursive(address issuer, address owner, bytes32 dscId, int scaleCoeffAcc) internal
    returns (bool executedCompletely) {
       Description memory dsc = descriptions[dscId];
        
       if (now > dsc.end) return true;   // expired: do nothing, treat as executed
       if (now < dsc.begin) {            // executable in future: create new fincontract
          createFincontractWithParties(issuer, owner, Scale(scaleCoeffAcc, dscId));
          return false;
       }
        
       if (dsc.prim == Primitive.ZERO) {
         return true;
       } else if (dsc.prim == Primitive.ONE) {
         return enforcePayment(issuer, owner, dsc.curr, scaleCoeffAcc * dsc.scaleCoeff);
         // don't currently handle the case when enforcePayment() returns false
       } else if (dsc.prim == Primitive.GIVE) {
        return executeRecursive(owner, issuer, dsc.dscId_1, scaleCoeffAcc * dsc.scaleCoeff); // issuer <--> owner
       } else if (dsc.prim == Primitive.AND) {
         bool executed1 = executeRecursive(issuer, owner, dsc.dscId_1, scaleCoeffAcc * dsc.scaleCoeff);
         bool executed2 = executeRecursive(issuer, owner, dsc.dscId_2, scaleCoeffAcc * dsc.scaleCoeff);
        return executed1 && executed2;
       } else if (dsc.prim == Primitive.OR) {
         createFincontractWithParties(issuer, owner, Scale(scaleCoeffAcc, dscId));   // sic! dsc.scaleCoeff handled inside
         return false;
       } else if (dsc.prim == Primitive.IF || dsc.prim == Primitive.SCALEOBS) {
         var gateway = Gateway(dsc.gateway);
         require((now - gateway.getTimestamp()) < FRESHNESS);
         if (dsc.prim == Primitive.IF) {
            return executeRecursive(issuer, owner, (gateway.getValue() != 0) ? dsc.dscId_1 : dsc.dscId_2, scaleCoeffAcc * dsc.scaleCoeff);
         } else if (dsc.prim == Primitive.SCALEOBS) {
            return executeRecursive(issuer, owner, dsc.dscId_1, gateway.getValue() * scaleCoeffAcc * dsc.scaleCoeff);
        }
       } else {
        return false;
       }
    }
    
    // Recursively execute and then delete a fincontact.
    function execute(bytes32 fctId)
    onlyOwner(fctId)
    onlyRegistered
    returns (bool executedCompletely) {
       var fct = fincontracts[fctId];
       bool executed = executeRecursive(fct.issuer, fct.owner, fct.dscId, 1);
       if (executed) {
         Executed(fctId);
       }
       // fincontract must be executable at most once, thus delete in any case.
       deleteFincontract(fctId);
       return executed;
    }

    // Create new fincontract depending on owner's choice (OR primitive).
    function choose(bytes32 fctIdOr, bool chooseFirst) internal
    onlyOwner(fctIdOr)
    returns (bytes32 ftcId) {
       var fct = fincontracts[fctIdOr];
       var dsc = descriptions[fct.dscId];
       require(dsc.prim == Primitive.OR);
       var chosenFctId = createFincontractWithParties(fct.issuer, fct.owner, 
         Timebound(dsc.begin, dsc.end, Scale(dsc.scaleCoeff, chooseFirst ? dsc.dscId_1 : dsc.dscId_2)));
       deleteFincontract(fctIdOr);
       return chosenFctId;
    }
    
    // Execute the chosen fincontract.
    function executeOr(bytes32 fctIdOr, bool chooseFirst)
    onlyOwner(fctIdOr)
    onlyRegistered
    returns (bool executedCompletely) {
       return execute(choose(fctIdOr, chooseFirst));
    }
    
    function deleteFincontract(bytes32 fctId) internal {
       if (fincontracts[fctId].dscId != 0) {
          delete fincontracts[fctId];
           Deleted(fctId);
       }
    }

    
    /***** TESTING *****/
    
    function simpleTest(address addr) returns (bytes32 fctId) {

        //For performance measurement: uncomment exactly one line
        //var testDsc = Zero();
        
        // 1. One
        //var testDsc = One(Currency.USD);
        
        // 2. Simple currency exchange
        var testDsc = And(Give(Scale(11,One(Currency.USD))),Scale(10,One(Currency.EUR)));
        
        // 3. ZCB
        //var testDsc = At(now + 1 minutes, Scale(10, One(Currency.USD)));
        
        // 4. Bond with 2 coupons
        /*
        var testDsc = 
                And(
                    And(
                        At(now + 1 minutes, One(Currency.USD)),
                        At(now + 2 minutes, One(Currency.EUR))),
                    At(now + 3 minutes, Scale(5, One(Currency.USD))));
        */
        // 5. European option
        //var testDsc = At(now + 1 minutes, Or(One(Currency.USD), One(Currency.EUR)));
        
        // 6. FC dependent on boolean Gateway, a.k.a Binary option
        //var testDsc = If(gatewayB, One(Currency.USD), One(Currency.EUR));
        
        // 7. FC dependent on numeric Gateway
        //var testDsc = ScaleObs(gatewayI, One(Currency.USD));
        
        return issueFor(createFincontract(testDsc), addr);
        
    }
    
    
      function complexScaleObsTest(address addr) returns (bytes32 fctId) {


        var testDsc = Scale(10,
                        And(
                            ScaleObs(gatewayI, Give(
                                Or(
                                    Scale(5, One(Currency.USD)),
                                    ScaleObs(gatewayI, Scale(10, One(Currency.EUR)))
                                ))),
                            If(gatewayB,
                                Zero(),
                                And(
                                    Scale(3, One(Currency.USD)),
                                    Give(Scale(7, One(Currency.EUR)))
                                )
                            )
                        )
                    );
        

        
        return issueFor(createFincontract(testDsc), addr);
        
    }  
    
    function timeboundTest(address addr, uint lowerBound, uint upperBound) returns (bytes32 fctId) {

        var testDsc = Timebound(lowerBound, upperBound, ScaleObs(gatewayI, Give(
                                    Or(
                                        Scale(5, One(Currency.USD)),
                                        Scale(10, One(Currency.EUR))
                                    ))));
        return issueFor(createFincontract(testDsc), addr);
    }

    /***** GATEWAYS *****/
    
    address gatewayI;    // int
    address gatewayB;   // bool
    
    function setGatewayI(address _addr) {
        gatewayI = _addr;
    }
    
    
    function setGatewayB(address _addr) {
        gatewayB = _addr;
    }
    
}













