pragma solidity ^0.4.13;

/**
 * 10X contract
 * Copyright 2017, TheWolf
 * 
 * An infinite crowdfunding lottery token
 * Using a permanent delivery of tokens as a reward to the lost bids.
 * With a bullet proof random generation algorithm and a lot of inovative features
 * With a state machine switching automatically from game mode to crowdfunding mode
 * 
 * Note: the code is free to use for learning purpose or inspiration, 
 * but identical code used in a commercial product or similar games
 * is prohibited: be creative!
 */
 
 
/*  Math operations with safety checks */
contract safeMath {
  function safeMul(uint a, uint b) internal constant returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal constant returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal constant returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal constant returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}


/* owned class */
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}


/* pass class */
contract pass is owned{
    bytes32 internalPass;

    function storePassword(string password)  internal onlyOwner{
        internalPass = sha256(password);
    }

    modifier protected(string password) {
        if ( internalPass!= sha256(password)) revert();
        _;
    }

    function changePassword(string oldPassword, string newPassword)  onlyOwner returns(bool) {
        if (internalPass== sha256(oldPassword)) {
            internalPass = sha256(newPassword); 
            return true;
        }
        return false;
    }
}


/* blacklist */
contract blacklist is owned, pass{
    
       // change the blacklist status of an address
    function setBlacklist(address _adr, bool _value, string _password ) onlyOwner external protected(_password){
        require(_adr>0);
        require(_adr!=owner);
        blacklist[_adr]=_value;
    }
   
    // change the blacklist status of an address internal version
    function setBlacklistInternal(address _adr, bool _value) onlyOwner internal {
        require(_adr>0);
        require(_adr!=owner);
        blacklist[_adr]=_value;
    }   
    
    // get the current status of an address, blacklisted or not?
    function checkBlacklist(address _adr ) constant external onlyOwner returns(bool){
        return blacklist[_adr];
    } 
    mapping (address => bool) blacklist;
}

/* ERC20 Contract definitions */
contract ERC20 {
  uint256 public totalETHSupply; // added to the ERC20 for convenience, does not change the protocol
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);
  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


/*  10X Token Creation and Functionality */
contract TokenBase is ERC20, blacklist, safeMath{

    uint public totalAddress;
    
    function TokenBase() { // constructor, first address is owner
        addr[0]=msg.sender;
        totalAddress=1;
    }
    
    // Send to the address _to, value money
    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value) { 
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    // Transfer money from one adress _from to another adress _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value ) { 
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }
    
    // get the current owner balance
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // transaction approval : check if everything is ok before transfering
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function getAddress(uint _index) constant returns(address adr)
    {
        require(_index>=0);
        require(_index<totalAddress);
        return(addr[_index]);
    }
    
    function getTotalAddresses() constant returns(uint) {
        return(totalAddress);
    }
 
    // allowance 
    function allowance(address _owner, address _spender) constant returns(uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (uint => address) addr;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
} 


contract THEWOLF10XToken is TokenBase{

    string public constant name = "10X Game"; // contract name
    string public constant symbol = "10X"; // symbol name
    uint256 public constant decimals = 18; // standard size
    string public constant version="1.46";

    bool public isfundingGoalReached;
    bool public isGameOn;  
    bool public isPaused;
    bool public isDebug;
    bool public isAutopilot;
    bool public isLimited;    
    bool public isPrintTokenInfinite;
    bool public isMaxCap10XReached;
    
    uint public limitMaxCrowdsale;
    uint public limitMaxGame;
    uint public fundingGoal; 
    uint public totalTokenSupply; 
    uint public timeStarted;
    uint public deadline; 
    uint public maxPlayValue;
    uint public betNumber;
    uint public restartGamePeriod;
    uint public playValue;
    uint public tokenDeliveryCrowdsalePrice;
    uint public tokenDeliveryPlayPrice;

    uint private seed;  
    uint private exresult;  
    uint256 public tokenCreationCap; 

    struct transactions { // Struct
        address playeraddress;
        uint time; 
        uint betinwai;
        uint numberdrawn;
        uint playerbet;
        bool winornot; 
    }

    event Create10X(address indexed _to, uint256 _value);
    event LogMsg(address indexed _from, string Msg);
    event FundingReached(address beneficiary, uint fundingRaised);
    event GameOnOff(bool state);
    event GoalReached(address owner, uint256 goal);
    event SwitchingToFundingMode(uint totalETHSupply, uint fundingCurrent); 
    event InPauseMode(uint date,bool status);
    
    mapping (uint => transactions) public bettable;

    // contructor debugging : 5000,2000,10,"10000000","0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db", "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c", "zzzzz",10,4
    // Testnet: https://gist.github.com/TheWolf-Patarawan/ae9e8ecf7300fc3abcc8d0863d6f4245
    // need this gas to create the contract: 6000000
    function THEWOLF10XToken(
        uint  _fundingGoalInEthers,
        uint  _tokenPriceForEachEtherCrowdsale,
        uint  _tokenPriceGame,
        uint  _tokenInitialSupplyIn10X,
        address _addressOwnerTrading1, 
        address _addressOwnerTrading2,  
        string _password,
        uint  _durationInDays
        )
    {
        require(_tokenPriceForEachEtherCrowdsale<=10000 && _tokenPriceForEachEtherCrowdsale>0);
        require(_tokenInitialSupplyIn10X * 1 ether>=10000000 * 1 ether); // cannot run with less than 10x4 Million 10X total, safety test in case slippy finger misses a 0
        require(msg.sender>0); // using 0 as address is not allowed

        isGameOn=false; // open the crowdsale per default
        isfundingGoalReached = false;
        isPaused=false;
        isMaxCap10XReached=false;
        fundingGoal = _fundingGoalInEthers * 1 ether;   // calculate the funding goal in eth
        // WARNING THIS IS FOR DEBUGGING, THIS VALUE MUST BE 0 IN THE LIVE CONTRACT
        //------------------------------------------------------------------------
        totalETHSupply = 100 ether;    // initial ETH funding for testing
        //------------------------------------------------------------------------
        owner = msg.sender;   // save the address of the contract initiator for later use
        balances[owner] =_tokenInitialSupplyIn10X * 2 ether; // tokens for the contract (used to deliver tokens to the player) 2x 10 Millions.
        balances[_addressOwnerTrading1] = _tokenInitialSupplyIn10X * 1 ether; // 10 M tokens for escrow 1 (buy)
        balances[_addressOwnerTrading2] = _tokenInitialSupplyIn10X * 1 ether; // 10 M tokens for escrow 2 (sale)        
        timeStarted=now;  // initialize the timer for the crowdsale, starting now
        tokenDeliveryCrowdsalePrice = _tokenPriceForEachEtherCrowdsale; // how many 10X tokens are delivered during the crowdsale
        tokenDeliveryPlayPrice=_tokenPriceGame; // price of a token when the game starts
        totalTokenSupply=_tokenInitialSupplyIn10X * 1 ether; // initial supply of tokens
        tokenCreationCap=_tokenInitialSupplyIn10X * 2 ether; // 20 Millions 10X tokens in the game /10 for ICO  / 10 for the game.
        storePassword(_password); // hash the password and store the admin password
        betNumber=0; // starting, no bets yet
        seed=now/4000000000000*3141592653589; // random seed
        exresult=1; // random result storage 
        deadline==now + (_durationInDays * 1 days); // date of the end of the current crowdsale starting now    
         
        restartGamePeriod=1; // automatic crowdfunding reset for this time period in days by default
        maxPlayValue=safeDiv(totalETHSupply,100); // at starting we can play no more than 2 Eth
        isLimited=false; // not limit for buying tokens
	    isPrintTokenInfinite= false; // we deliver only the tokens we have in stock of true we mint on demand.
        limitMaxCrowdsale=0; // the upper limit in case of we want to limit the value per transaction in crowdsale mode
        isAutopilot=false; // do not let the contract change its status alone. Set it to true if the owner cannot manage the contract anymore.
        limitMaxGame= 2 ether; // cannot play more than 2 ether at the game, if 0 unlimited
        
    }
     
    // determines the token rate 
    function tokenRate() constant returns(uint) { 
        if (now>timeStarted && now<deadline && !isGameOn) return tokenDeliveryCrowdsalePrice; // when we are in crowdsale mode
        return tokenDeliveryPlayPrice; // when the game is on
    }

    // Generates and delivers the tokens and the ethers 
    function makeTokens() payable  returns(bool) {
        uint256 tokens;
        uint256 checkTokenSupply;
    
        maxPlayValue=safeDiv(totalETHSupply,100);
        playValue=msg.value;
        
        // check if we exceed the maximum bet possible according to the fund we have.
        if (isGameOn==true) {
            if (playValue>maxPlayValue) {
                  LogMsg(msg.sender, "This bet exceed the maximum play value, we cannot accept it, try with a lower amount.");
                  revert();
            }
        }
        
        // case of we limit the number of transaction in the Crowdsale mode
        if (isLimited==true && isGameOn==false) {
            if (balances[msg.sender]>limitMaxCrowdsale) {
                LogMsg(msg.sender, "limiting: I am in limited crowdsale mode. You have too many tokens to participate.");
                revert();
                }
        }
       
        if (now<timeStarted)  return false; //do not create tokens before it is started
        if (playValue == 0)  {
                //LogMsg(msg.sender, "makeTokens: Cannot receive 0 ETH."); // do not log message, no need to help hackers
                return false; // cannot receive 0 ETH
        }
        if (msg.sender == 0)  return false; // sender cannot be null 
        
        if (isGameOn) {
            // check if we are out of limit
            if (limitMaxGame>0) {  // 0 is unlimited <>0 then we limit the maximum bet for the game
                if (playValue>limitMaxGame) {
                      LogMsg(msg.sender, "Your bet is > to the limitMaxGame limit. Check the website to see what is the maximum value to bet in the game at this time."); 
                      revert();
                }
            }
            // this is when the game is on (crowdsale finished)    
            uint bet=lastDecimal(playValue); // this is the number the player bet
            uint drawn=rand(0,9);
            // store the bets so that the website can list the results
            // address playeraddress;
            // uint time;
            // uint betinwai;
            // uint numberdrawn;
            // bool winornot;
            bettable[betNumber].playeraddress=msg.sender;
            bettable[betNumber].time=now;
            bettable[betNumber].betinwai=msg.value;
            bettable[betNumber].numberdrawn=drawn;
            bettable[betNumber].playerbet=bet;
            
            // check if win or not
            if (bet==drawn) bettable[betNumber].winornot=true;
            else bettable[betNumber].winornot=false;
            
            // case 1 the player wins => we send x*his bet
            if (bettable[betNumber].winornot==true) { 
                uint moneytosend=playValue*tokenRate();
                require(totalETHSupply>moneytosend); // not enough money? cancel the transaction
                sendEthBack(moneytosend); // x time the ETH bet back to the player and eventually switch to ICO mode
            }else{
                // case 2 the player looses => we send tokenrate*his bet
                if (!isMaxCap10XReached) { // we still have tokens in stock
                    tokens = safeMul(msg.value,tokenRate()); // send 10X * current rate
                    checkTokenSupply = safeAdd(totalTokenSupply,tokens); // temporary variable to check the total supply
                    if (tokens >= totalTokenSupply-(10 ether)) {  // we cannot run the game with less than 100 ETH
                        LogMsg(msg.sender, "Game mode: You are running out of tokens, please add more.");
                        // need to switch to crowdfunding mode
                        betNumber++;
                        resetInternal(restartGamePeriod); // do a new ICO for x day. x is 1 by default but can be changed with externals
                        return false;
                    }
                // case 3, we have reached the max cap, we cannot deliver any tokens anymore, but the game can continue
                }else{
                     LogMsg(msg.sender, "Cannot deliver tokens. All tokens have been distributed. Hopefully the owner will mint more."); 
                }
                if (checkTokenSupply >= tokenCreationCap) {  //
                    isMaxCap10XReached=true;
                    LogMsg(msg.sender, "Game mode: We have reached the maximum capitalization."); 
                    betNumber++;
                    return false;
                }
                // we are here -> giving tokens to the player.
                totalTokenSupply = checkTokenSupply;
                balances[msg.sender] += tokens;
            }
            Create10X(msg.sender, tokens); // event
            betNumber++; // increase the bet number index
        }else { 
            // crowdfunding mode
            tokens = safeMul(msg.value,tokenRate()); // send 10X * current rate
            checkTokenSupply = safeAdd(totalTokenSupply,tokens); // temporary variable to check the total supply            
            if (!isMaxCap10XReached) {
                // case 4, we are in normal crowdfunding mode
                if (tokens >= totalTokenSupply-(10 ether) || totalTokenSupply<=10 ether) {  //
                    LogMsg(msg.sender, "Crowdfunding mode: You are running out of tokens, please add more."); 
                    return false; // cannot continue
                }
            }else{
                // case 3, we have reached the max cap, we cannot deliver any tokens anymore.
                if (isAutopilot) {
                    isGameOn=true; // we switch in game mode, since there is no reason to raise any money. End of the crowdsale
                    GameOnOff(isGameOn);
                    LogMsg(msg.sender, "Max Cap reached, switching to game mode. End of the Crowdsale"); 
                }else{
                    LogMsg(msg.sender, "End of the crowdsale. Autopilot is off and I am waiting for the owner to unPause me."); 
                    // we are in manual mode, so we pause the game and wait that owner decide.
                     isGameOn=true; // we prepare everything to switch to game when owner is ready.
                     GameOnOff(isGameOn);
                     isPaused=true;
                     InPauseMode(now,isPaused);
                }
            }
            // here if we are still in crowdsale mode
            updateStatusInternal(); // are we at the end of the crowdsale and other test?
            totalETHSupply+=msg.value; // updating the total ETH we received since if we are here that meant that the transaction was successfull
            balances[msg.sender] += tokens; // update the balance of the sender with the tokens he purchased
            totalTokenSupply = checkTokenSupply; // update the total token supplied 
          
        }
        return true;
    }

    function() payable {
        require(blacklist[msg.sender]!=true); // blacklist system do not access if in the blacklist
        if (isDebug) {
               LogMsg(msg.sender, "Debugging something...we will be back soon. Your transaction has been cancelled.");
               revert();
        }
        if (!isPaused) {  // if the contract is not paused, otherwise, do nothing
            if (!makeTokens()) { 
                LogMsg(msg.sender, "10X token cannot be delivered. Transaction cancelled.");
                revert();
                
            }
        }else {
                LogMsg(msg.sender, "10X is paused. Please wait until it is running again.");
                revert();
        }
    }
    
    // Reset manually the ICO to do another crowdfunding from external
    function reset(uint _value_goal, uint _value_crowdsale, uint _value_game,uint _value_duration, string _password) external onlyOwner protected(_password){
        isGameOn=false;
        isfundingGoalReached = false;
        isPaused=false;
        InPauseMode(now,isPaused);
        isMaxCap10XReached=false;
        tokenDeliveryCrowdsalePrice=_value_crowdsale;
        tokenDeliveryPlayPrice=_value_game;
        fundingGoal = _value_goal * 1 ether;
        owner = msg.sender;
        deadline = now + ( _value_duration * 1 days);
        timeStarted=now;
        updateStatusInternal();
    }
    
    // Reset automatically the ICO to do another crowdfunding, duration is in seconds, this is the internal version cheaper in gas
    function resetInternal( uint _value_duration) internal {
        isGameOn=false; // game mode is off we are doing a crowdfunding
        isfundingGoalReached = false; 
        isPaused=false;
        InPauseMode(now,isPaused);
        isMaxCap10XReached=false;
        deadline = now + (_value_duration* 1 days); // set new duration in days
        timeStarted=now;
    }   
    
    // get the info of a bet in a json table, I want it public for transparency, also the website need this.
    function getBet(uint256 _value) public constant returns(uint, uint, uint, uint,bool)  {
        require(_value<betNumber && _value>=0);
        return (bettable[_value].time,bettable[_value].betinwai,bettable[_value].numberdrawn,bettable[_value].playerbet,bettable[_value].winornot);
    }

    // Sends eth to ethFundAddress (the contract owner) manually 
    function sendEth(uint256 _value) external onlyOwner {
        require(_value >= totalETHSupply);
        if(!owner.send(_value) ) { // using send, checking that the operation was successful
          LogMsg(msg.sender, "sendEth: 10X cannot send this value of ETH, transaction cancelled.");
          revert();
        }
        // if here send was sucessful
    }
    
    // Sends eth back to the player 
    function sendEthBack(uint256 _value)  internal {
        require (msg.sender>0); 
        require (msg.sender != owner); // owner cannot send to himself
        uint tmpvalue=_value; // debugging otherwise cannot see this value in the debugger
        require (_value>0);
        if (_value > totalETHSupply-(10 ether) && totalETHSupply>=10 ether ) { // 100 ETH is the minium for the Bank to run, also check hack attempt with impossible values.
            resetInternal(restartGamePeriod); // in days, restartGamePeriod can be set to whatever
            LogMsg(msg.sender, "sendEthBack: not enough ETH to perform this operation.");
            if (!isAutopilot) { // if we are not in auto pilot, pause the game and let the owner decide.
                isPaused=true;
                InPauseMode(now,isPaused);
            }
        }
        if(!msg.sender.send(_value)  ) {
            LogMsg(msg.sender, "sendEthBack: 10X cannot send this value of ETH. Refunding.");
            revert();
      }
      // if here send was sucessful
    }
        
    // checks if the goal or time limit has been reached and ends the campaign (switch back in game mode) 
    function updateStatusInternal() internal returns(bool){
        if (now >= deadline) { // did we reached the deadline?
            if ( totalETHSupply >= fundingGoal){ // did we raised enough ETH?
                isfundingGoalReached = true; // end the crowdfunding
                GoalReached(owner, totalETHSupply); // shoot an event to log it
            }
            isGameOn = true; // crowdsale is closed, let's play the game.
            GameOnOff(isGameOn);
            if (!isAutopilot) { // we are not in autopilot mode, then pause the game and let the owner decide when to switch to game more.
                isPaused=true;
                InPauseMode(now,isPaused);
            }
        }else{ isGameOn=false;} // still in crowdfunding mode, let's continue in this mode
        if (totalTokenSupply >= tokenCreationCap) {
            isMaxCap10XReached=true;
        } else isMaxCap10XReached=false;
        
        return(isGameOn);
    }  
    
    // checks if the goal or time limit has been reached and ends the campaign (switch back in game mode) 
    function updateStatus() external onlyOwner returns(bool){ // 
        if (now >= deadline) { // did we reached the deadline?
            if ( totalETHSupply >= fundingGoal){ // did we raised enough ETH?
                isfundingGoalReached = true;
                GoalReached(owner, totalETHSupply); // shoot an event to log it
            }
            isGameOn = true; // crowdsale is closed, let's play the game.
            GameOnOff(isGameOn);
             if (!isAutopilot) { // we are not in autopilot mode, then pause the game and let the owner decide when to switch to game more.
                isPaused=true;
                InPauseMode(now,isPaused);
            }
        }else{ isGameOn=false;}
        
        if (totalTokenSupply >= tokenCreationCap) {
            isMaxCap10XReached=true;
        } else isMaxCap10XReached=false;
        
        return(isGameOn);
    } 
  
    // Add ETH manually
    function addEth() payable external onlyOwner{
      if (!isGameOn) {
              LogMsg(msg.sender, "addEth: 10X crowdfunding is has not ended. Cannot do that now.");
              revert();
      }
      totalETHSupply += msg.value;
    }
    
    // Add tokens manually to the game in ether
    function addTokens(uint256 _mintedAmount,string _password)  external onlyOwner protected(_password) {
      require(_mintedAmount * 1 ether <= 10000000 * 1 ether); // do not add more than 1 Million token, avoid mistake
      safeAdd(totalTokenSupply ,_mintedAmount * 1 ether);      
    }
    
    // Sub tokens manually from the game
    function subTokens(uint256 _mintedAmount,string _password)  external onlyOwner protected(_password) {
        require(_mintedAmount * 1 ether <= 10000000 * 1 ether); // do not sub more than 1 Million Ether, avoid mistake
        require(_mintedAmount * 1 ether > totalTokenSupply); // do not go under 0
        safeSub(totalTokenSupply ,_mintedAmount * 1 ether);
    }
    
    // Give tokens to someone
    function giveToken(address _target, uint256 _mintedAmount,string _password) external onlyOwner protected(_password) {
        safeAdd(balances[_target],_mintedAmount);
        safeAdd(totalTokenSupply,_mintedAmount);
        if (isPrintTokenInfinite==true) Transfer(0, owner, _mintedAmount); // if we want to mint ad infinity create token from thin air
        Transfer(owner, _target, _mintedAmount); // event
    }
    
    // Take tokens from someone
    function takeToken(address _target, uint256 _mintedAmount, string _password) external onlyOwner protected(_password) {
        safeSub(balances[_target], _mintedAmount);
        safeSub(totalTokenSupply,_mintedAmount);
        Transfer(0, owner, _mintedAmount); // event
        Transfer(owner, _target, _mintedAmount); // event
    }

    // Is an expeditive way to switch from crowdsale to game mode
    function switchToGame(string _password) external  onlyOwner protected(_password) {
      require(!isGameOn); // re-entrance check
      isGameOn = true; // start the game
      GameOnOff(isGameOn);
    }
    
    // Is an expeditive way to switch from game mode to crowdsale
    function switchToCrowdsale(string _password) external  onlyOwner protected(_password) {
      require(isGameOn); // re-entrance check
      isGameOn = false; // start the game
      GameOnOff(isGameOn);
    }    
    
    // random number (miner proof)
    function rand(uint _min, uint _max) internal returns (uint){
        require(_min>=0);
        require(_max>_min); 
        bytes32 hashVal = bytes32(block.blockhash(block.number - exresult));
        if (seed==0) seed=uint(hashVal); 
        else {
            safeAdd(safeDiv(seed,2),safeDiv(uint(hashVal),2));
        }
        uint result=safeAdd(uint(hashVal)%_max,_min)+1;
        exresult=safeAdd(result%200,1);
        return uint(result);
    }
    
    // Destroy this contract (cry)
    function destroyContract(string _password) external onlyOwner protected(_password) {
        selfdestruct(owner); // commit suicide!
    }
    
    // convert a string to bytes
    function stringToBytes( string _s) internal constant returns (bytes){
        bytes memory b3 = bytes(_s);
        return b3;
    }
    
    // take the last byte and extract a number between 1-9 (drawn number)
    function lastChar(string _x)  internal constant returns (uint8) {
        bytes memory a=stringToBytes(_x);
        if (a.length<=1) revert();
        uint8 b=uint8(a[a.length-1])-48;
        b=b%10;
        if (b<0) {
            LogMsg(msg.sender, "tochar: Impossible, address logged");
            if (msg.sender!=owner) blacklist[msg.sender]=true;
            revert();
        }
        return b;
    }
    
    // get the last char from a string exclude 0
    function lastCharNoZero(string _x)  internal constant returns (uint8) {
        bytes memory a=stringToBytes(_x);
        uint len=a.length;
        if (len<=1) revert();
        uint8 b=uint8(a[len-1])-48;
        b=b%10;
        while (b==0 && len>0) {
            len--;
            b=uint8(a[len-1])-48;
        }
        if (b<0) {
            LogMsg(msg.sender, "tochar: Impossible, address blacklisted");
            blacklist[msg.sender];
            revert();
        }
        return b;
    }
    
    // last decimal ex:"1945671234000000000" => 4
    function lastDecimal(uint256 _x)  internal constant returns (uint) {
        //$a=$x/(pow(10,$i));
	    //$b=$a%10;
        uint a;
        for (uint i=1;i<20;i++) {
            a=(_x/(10**i)%10);
            if (a>0) return a;
        }
        return 0;
    }    
    
    // change the current play price
    function setPlayPrice(uint _value, string _password )  onlyOwner external protected(_password) {
        require(_value<=1000); // security, we can get crazy and offer 1000 tokens for a special promotion but no more, written in the marble of the blockchain
        tokenDeliveryPlayPrice=_value;
    }    
 
    // get play price
    function getTotalTokenSupply()  constant external returns(uint){
        return tokenDeliveryPlayPrice;
    } 
        
    // Change the max capitalisation token
    function setMaxCap10X(uint _value, string _password )  onlyOwner external protected(_password) {
        require(_value>tokenCreationCap); // we cannot set the max token capitalization lower than what it is otherwise we f*ck up the logic of the game and cannot go back
        require(_value>totalTokenSupply); // of course, the new max capitalization must be higher than the current token supply, otherwise, what is the point?
        totalTokenSupply=_value; // magic, creation of money
        isMaxCap10XReached=false;

    } 
    
    // get number of tokens available for delivery
    function getMaxCap10X()  constant external returns(uint){
        return tokenCreationCap;
    } 
        
  
    // Change the limit for a transaction at the crowdsale: in case we do not want people to buy too much at the time, we can limit the max value a transaction can be
    function setLimitMaxCrowdsale(uint _value, string _password )  onlyOwner external protected(_password){
        require(_value>=0); // of course cannot be 0
        require(_value<100000 ether); // if it is >100000 there must be an error or a mistake
        limitMaxCrowdsale=_value;
    } 
    
    // Get the current limit 
    function getLimitMaxGame()  constant external returns(uint){
        return limitMaxGame;
    } 
    
    // Change the limit for a transaction in the game : for example we have ETH in the bank but want to limit the game to bets <=2 ETH
    function setLimitGame(uint _value, string _password )  onlyOwner external protected(_password){
        require(_value>=0); // of course cannot be 0
        require(_value<100000 ether); // if it is >100000 there must be an error or a mistake
        limitMaxGame=_value;
    } 
    
    // Get the current limit 
    function getLimitMaxCrowdsale()  constant external returns(uint){
        return limitMaxCrowdsale;
    } 
    
    // get max the current crowdsale price
    function getCrowdsalePrice( )  constant external returns(uint){
        return tokenDeliveryCrowdsalePrice;
    } 
    
    // change the current crowdsale status, different variant just in case, spend some gas for nothing.
    function setGameStatus(bool _value,string _password )  onlyOwner external protected(_password) {
        isGameOn=_value;
        GameOnOff(isGameOn);
    } 
        
    // get the status of the game true= game / false = crowdfunding
    function getGameStatus( )  constant external returns(bool){
        return isGameOn;
    } 
    
    // limit the ICO to 1 transaction per address
    function setIsLimited(bool _value,string _password )  onlyOwner external protected(_password) {
        isLimited=_value;
    } 
        
    // get limited status
    function getIsLimited( )  constant external returns(bool){
        return isLimited;
    } 
    
    // change the current crowdsale price
    function setCrowdsalePrice(uint _value,string _password )  onlyOwner external protected(_password) returns(bool){
        require(_value<=10000); // crowdsale price cannot be >10,000 / ETH let's not do like SNT
        tokenDeliveryCrowdsalePrice=_value;
        return true;
    } 
     
    // change the current contract owner
    function changeContractOwner(address _value,string _password) onlyOwner external  protected(_password){
        owner = _value;
    }
    
    // get the current contract owner
    function getContractOwner( )  constant external onlyOwner returns(address){
        return owner;
    } 
    
    // change the restart time period for the temp ICO
    function setRestartGamePeriod(uint _value, string _password )  onlyOwner  external  protected(_password){
        require(_value>=1 && _value<= 365); // value is in days, cannot be less than 1 day or > 365 days
        restartGamePeriod=_value; // in days 
    }   
    
}
