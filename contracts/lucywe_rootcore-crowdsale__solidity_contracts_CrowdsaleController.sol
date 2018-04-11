pragma solidity ^0.4.15;
import './SmartTokenController.sol';
import './Utils.sol';
import './Managed.sol';
import './Pausable.sol';
import './SmartToken.sol';
import './interfaces/ISmartToken.sol';


/*

    The CrowdsaleController allows contributing ether in exchange for Rootcoin tokens
    The price remains fixed for the entire duration of the crowdsale
    Presale contributes are allocated (manually) with additional 20% tokens from the beneficiary tokens.
    Presale contribute mst use pre-verified addresses. (KYC)
*/
contract CrowdsaleController is SmartTokenController, Managed, Pausable {

    

    uint256 public constant DURATION = 14 days;                 // crowdsale duration  
    uint256 public constant TOKEN_PRICE_N = 1;                  // initial price in wei (numerator)
    uint256 public constant TOKEN_PRICE_D = 1000;               // initial price in wei (denominator) (1000 wei equals 1 token)
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;    // maximum gas price for contribution transactions
    uint256 public constant MAX_CONTRIBUTION = 40 ether;        // maximum ether allowed to contribute by an unauthorized single account
    uint256 public constant SOFTCAP_GRACE_DURATION = 10;//86400;     // crowdsale softcap reached grace duration in seconds (24 hours) (use 8 seconds for tests)
    uint256 public TOTAL_ETHER_CAP = 110000 ether;             // overall ether contribution cap. use 1100000 for test 
    uint256 public TOTAL_ETHER_SOFT_CAP = 100000 ether;         // overall ether contribution soft cap. use 1000000 for test 
    
    //Presale constants
    uint256 public constant PRESALE_DURATION = 14 days;               // pressale duration
    uint256 public constant PRESALE_MIN_CONTRIBUTION = 200 ether;     // pressale min contribution
    
    //Token constants
    string public constant TOKEN_NAME = "Rootcoin"; //Token name
    string public constant TOKEN_SYM = "RCT";       //Token symbol
    uint8 public constant TOKEN_DEC = 18;           //Token decimals
    
    
    //State variables
    uint256 public startTime = 0;                   // crowdsale start time (in seconds)
    uint256 public endTime = 0;                     // crowdsale end time (in seconds)
    uint256 public totalEtherContributed = 0;       // ether contributed so far
    address public beneficiary = 0x0;               // address to receive all ether contributions
    mapping(address => bool) public whiteList;  //whitelist of accounts that can participate in presale and also contribute more than MAX_CONTRIBUTION
    uint256 public numOfContributors = 0;                   // public contributors counter
     

    // triggered on each contribution
    event Contribution(address indexed _contributor, uint256 _amount, uint256 _return);

    /**
        @dev constructor
        @param _startTime      crowdsale start time
        @param _beneficiary    address to receive all ether contributions
    */
    function CrowdsaleController(uint256 _startTime, address _beneficiary)
        SmartTokenController(new SmartToken(TOKEN_NAME, TOKEN_SYM, TOKEN_DEC))
        validAddress(_beneficiary)
        earlierThan(_startTime)
    {
        startTime = _startTime;
        endTime = startTime + DURATION;
        beneficiary = _beneficiary;
        token.disableTransfers(true);
    }

    // verifies that the gas price is lower than 50 gwei
    modifier validGasPrice() {
        assert(tx.gasprice <= MAX_GAS_PRICE);
        _;
    }

    // ensures that it's earlier than the given time
    modifier earlierThan(uint256 _time) {
        assert(now < _time);
        _;
    }

    // ensures that the current time is between _startTime (inclusive) and _endTime (exclusive)
    modifier between(uint256 _startTime, uint256 _endTime) {
        assert(now >= _startTime && now < _endTime);
        _;
    }

    // ensures that we didn't reach the soft ether cap, and sets the end time time when we do. Must be placed before the etherCapNotReached.
    modifier etherSoftCapNotReached(uint256 _contribution) {
        if (safeAdd(totalEtherContributed, _contribution) >= TOTAL_ETHER_SOFT_CAP) {
            endTime = now + SOFTCAP_GRACE_DURATION;
        }
        _;
    }

    // ensures that we didn't reach the ether cap
    modifier etherCapNotReached(uint256 _contribution) {
        assert(safeAdd(totalEtherContributed, _contribution) <= TOTAL_ETHER_CAP);
        _;
    }

    // verifies that the presale contribution is more than presale minimum
    modifier validatePresaleMinPrice() {
        require(msg.value >= PRESALE_MIN_CONTRIBUTION);
        _;
    }

    // verifies that the presale contribution is from predefined address - TBD (not in use unless we decide to make a whitelist.)
    modifier validatePresaleAddress() {
         require(whiteList[msg.sender] == true);
        _;
    }

    // verifies that the total contributions from contributing account do not reach max alloewed unless it is on the whitelist.
    modifier maxAccountContributionNotReached() {   
        assert(safeAdd(msg.value, safeMul(token.balanceOf(msg.sender), TOKEN_PRICE_N) / TOKEN_PRICE_D) <= MAX_CONTRIBUTION || whiteList[msg.sender]==true);
        _;
    }

    /**
        @dev computes the number of tokens that should be issued for a given contribution

        @param _contribution    contribution amount

        @return computed number of tokens
    */
    function computeReturn(uint256 _contribution) public constant returns (uint256) {
        // return safeMul(_contribution, TOKEN_PRICE_D) / TOKEN_PRICE_N;
        return safeMul(_contribution, TOKEN_PRICE_D) / TOKEN_PRICE_N;
    }

    /**
        @dev updates the number of contributors
    */
    function upadateContributorsCount(uint256 _tokenAmount) private {
        if (token.balanceOf(msg.sender) == _tokenAmount ) 
            numOfContributors++;
    }

    /**
        @dev adds a whitelist address for which there is no max contribution and is alloewed to participate in the presale.

        @param _address    verified contributor address

        @return true
    */
    function addToWhitelist(address _address)
    public
    managerOnly
    returns (bool added)
    {
        whiteList[_address] = true;
        return true;
    }

    /**
        @dev disables an existing whitelist address from participating presale.

        @param _address    verified contributor address to be removed

        @return true
    */
    function removeFromWhitelist(address _address)
    public
    managerOnly
    returns (bool added)
    {
        whiteList[_address] = false;
        return true;
    }

    /**
        @dev ETH contribution
        can only be called during the crowdsale

        @return tokens issued in return
    */
    function contributeETH()
        public
        payable
        between(startTime, endTime)
        whenNotPaused
        maxAccountContributionNotReached
        returns (uint256 amount)
    {
        return processContribution();
    }

     /**
        @dev handles contribution during presale (min 200 ether)
        can only be called 14 days before the crowdsale start date

        @return tokens issued in return
    */
    function contributePreSale()
        public
        payable
        between(safeSub(startTime,PRESALE_DURATION), startTime)
        whenNotPaused
        validatePresaleMinPrice
        validatePresaleAddress
        returns (uint256 amount)
    {
        return processContribution();
    }

     /**
        @dev handles contribution with Fiat - for 
        can only be called by manager 

        @return tokens issued in return
    */
    function contributeFiat(address _contributor, uint256 _amount)
        public
        payable
        managerOnly
        between(safeSub(startTime,PRESALE_DURATION), safeAdd(startTime, DURATION))
        whenNotPaused
        returns (uint256 amount)
    {
        uint256 tokenAmount = computeReturn(_amount);
    
        totalEtherContributed = safeAdd(totalEtherContributed, _amount); // update the total contribution amount
        token.issue(_contributor, tokenAmount); // issue new funds to the contributor's address, provided by the manager, in the smart token
        token.issue(beneficiary, tokenAmount); // issue tokens to the beneficiary

        Contribution(_contributor, msg.value, tokenAmount);
        return tokenAmount;
    }

    /**
        @dev handles contribution logic
        note that the Contribution event is triggered using the sender as the contributor, regardless of the actual contributor

        @return tokens issued in return
    */
    function processContribution() private
        active
        etherSoftCapNotReached(msg.value)
        etherCapNotReached(msg.value)
        validGasPrice
        returns (uint256 amount)
    {
        uint256 tokenAmount = computeReturn(msg.value);
        assert(beneficiary.send(msg.value)); // transfer the ether to the beneficiary account
        totalEtherContributed = safeAdd(totalEtherContributed, msg.value); // update the total contribution amount
        token.issue(msg.sender, tokenAmount); // issue new funds to the contributor in the smart token
        token.issue(beneficiary, tokenAmount); // issue tokens to the beneficiary
        upadateContributorsCount(tokenAmount);
        Contribution(msg.sender, msg.value, tokenAmount);
        return tokenAmount;
    }

    // fallback
    function() payable {
        contributeETH();
    }
}
