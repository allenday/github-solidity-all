/// @title Tru Reputation Token Sale
/// @notice Tru Reputation Protocol Sale contract based on Open Zeppelin and 
/// TokenMarket. This Sale is modified to include the following features:
/// - Crowdsale time period
/// - Bonus of 12.5%
/// @author Ian Bray
pragma solidity 0.4.18;

import "./supporting/Haltable.sol";
import "./supporting/Ownable.sol";
import "./supporting/SafeMath.sol";
import "./TruReputationToken.sol";


contract TruSale is Ownable, Haltable {
    
    using SafeMath for uint256;
  
    /// @notice Tru Reputation Token - the token being sold
    TruReputationToken public truToken;

    /// @notice Start and end timestamps of Sale window
    uint256 public saleStartTime;
    uint256 public saleEndTime;

    /// @notice Number of unique addresses that have purchased from this contract
    uint public purchaserCount = 0;

    /// @notice Multisig Address where funds are collected
    address public multiSigWallet;

    /// @notice Base Exchange of Tru Reputation Token to ETH - 1 TRU = 1000 TRU per ETH
    uint256 public constant BASE_RATE = 1000;
  
    /// @notice Exchange of Tru Reputation Token to ETH with Sale Bonus of 25% - 1250 TRU per ETH
    uint256 public constant PRESALE_RATE = 1250;

    /// @notice Exchange of Tru Reputation Token to ETH with Sale Bonus of 12.5% - 1125 TRU per ETH
    uint256 public constant SALE_RATE = 1125;

    /// @notice Minimum purchase amount for Sale in Ether (1 Ether) (25 x POWER(10,18))
    uint256 public constant MIN_AMOUNT = 1 * 10**18;

    /// @notice Maximum purchase amount for Sale in Ether (20 Ether) (20 x POWER(10,18))
    uint256 public constant MAX_AMOUNT = 20 * 10**18;

    /// @notice Amount raised in this Sale in Wei
    uint256 public weiRaised;

    /// @notice Cap on Sale in Wei - Set by each Sale Constructor
    uint256 public cap;

    /// @notice Variable to mark if the Sale is complete or not
    bool public isCompleted = false;

    /// @notice Variable to mark if the Sale is Pre-Sale
    bool public isPreSale = false;

    /// @notice Variable to mark if the Sale is a Crowdsale
    bool public isCrowdSale = false;

    /// @notice Vairable to mark number of Tokens sold
    uint256 public soldTokens = 0;

    /// @notice How much ETH has been raised in this Sale by each participant address
    mapping(address => uint256) public purchasedAmount;

    /// @notice How many TRU tokens have been purchased by each Purchaser in this Sale
    mapping(address => uint256) public tokenAmount;

    /// @notice Mapping of whitelisted addresses for this sale
    mapping (address => bool) public purchaserWhiteList;

    /// @notice Token Purchase logging event
    /// @param purchaser Purchaser who paid for the tokens
    /// @param recipient Recipient who received the tokens
    /// @param weiValue Amount raised in wei used in the purchase
    /// @param tokenAmount Amount of tokens given in exchange
    event TokenPurchased(
        address indexed purchaser, 
        address indexed recipient, 
        uint256 weiValue, 
        uint256 tokenAmount);

    /// @notice Whitelist purchaser event
    /// @param purchaserAddress Address added to Whitelist
    /// @param whitelistStatus Status on Whitelist
    /// @param executor Address which execute the update
    event WhiteListUpdated(address indexed purchaserAddress, 
        bool whitelistStatus, 
        address indexed executor);

    /// @notice Sale End Time Changed Event
    /// @param oldEnd Original time the Sale ends at
    /// @param newEnd New time the Sale ends at
    /// @param executor Address which execute the update
    event EndChanged(uint256 oldEnd, 
        uint256 newEnd, 
        address indexed executor);

    /// @notice Sale Completed Event
    /// @param executor Address which completed the Sale
    event Completed(address indexed executor);

    modifier onlyTokenOwner(address _tokenOwner) {
        require(msg.sender == _tokenOwner);
        _;
    }

    /// @notice Contract constructor
    /// @param _startTime The Start Time of the Sale as a uint256
    /// @param _endTime The End Time of the Sale as a uint256
    /// @param _token The Tru Reputation Token Contract Address used to mint tokens purchases
    /// @param _saleWallet The MultiSig wallet address used to hold funds for the Sale
    function TruSale(uint256 _startTime, 
        uint256 _endTime, 
        address _token, 
        address _saleWallet) public {

        // _token must be valid
        require(_token != address(0));

        // Only the owner of the _token can construct a sale of it
        TruReputationToken tToken = TruReputationToken(_token);
        address tokenOwner = tToken.owner();

        createSale(_startTime, _endTime, _token, _saleWallet, tokenOwner);
    }

    /// @notice Default buy function
    function buy() public payable stopInEmergency {
        // Check that the Sale is still open and the Cap has not been reached
        require(checkSaleValid());

        validatePurchase(msg.sender);
    }

    /// @notice Function to add or disable a purchaser from AML Whitelist
    /// Moved from Bool on _status to int- 0 for false, 1 for true, due to
    /// type safety when calling from Web3 potentially opening an exploit in Solidity
    /// Bool arguments in public function in Solidity are, basically, dangerous
    /// @param _purchaser address of the purchaser to be added to the Whitelist
    /// @param _status the Status for the purchaser on the WhiteList- 0 for disabled, 
    /// 1 for enabled
    function updateWhitelist(address _purchaser, uint _status) public onlyOwner {
        require(_purchaser != address(0));
        bool boolStatus = false;
        if (_status == 0) {
            boolStatus = false;
        } else if (_status == 1) {
            boolStatus = true;
        } else {
            revert();
        }

        WhiteListUpdated(_purchaser, boolStatus, msg.sender);
        purchaserWhiteList[_purchaser] = boolStatus;
    }

    /// @notice Function to change the end time of the Sale
    function changeEndTime(uint256 _endTime) public onlyOwner {
        
        // _endTime must be greater than or equal to saleStartTime
        require(_endTime >= saleStartTime);
        
        // Fire Event for time Change
        EndChanged(saleEndTime, _endTime, msg.sender);

        // Change the Sale End Time
        saleEndTime = _endTime;
    }

    /// @notice Function to check whether the Sale has ended
    /// @return Returns true if the sale has been ended or the Cap has been reached, 
    /// false if it has not 
    function hasEnded() public constant returns (bool) {
        bool isCapHit = weiRaised >= cap;
        bool isExpired = now > saleEndTime;
        return isExpired || isCapHit;
    }
    
    /// @notice Function to validate that the buy is occuring within the Sale window and before the Cap is reached
    /// @return Returns true if the buy meets the criteria, false if it does not 
    function checkSaleValid() internal constant returns (bool) {
        bool afterStart = now >= saleStartTime;
        bool beforeEnd = now <= saleEndTime;
        bool capNotHit = weiRaised.add(msg.value) <= cap;
        return afterStart && beforeEnd && capNotHit;
    }

    /// @notice Haltable purchase validation function. Performs all pre-checks before processing purchase
    /// @param _purchaser Wallet Address of the Purchaser
    function validatePurchase(address _purchaser) internal stopInEmergency {
    
        // _purchaser must be valid
        require(_purchaser != address(0));
    
        // Value must be greater than 0
        require(msg.value > 0);

        buyTokens(_purchaser);
    }

    /// @notice Function to forward all raised funds to the Multisig Wallet used to disperse funds
    function forwardFunds() internal {
        multiSigWallet.transfer(msg.value);
    }

    /// @notice Internal function used to encapsulate more complex constructor logic and ensure
    /// sale is being created by owner of the TruReputationToken contract.
    function createSale(
        uint256 _startTime, 
        uint256 _endTime, 
        address _token, 
        address _saleWallet, 
        address _tokenOwner) 
        internal onlyTokenOwner(_tokenOwner) 
    {
        // _startTime must be greater than or equal to now
        require(now <= _startTime);

        // _endTime must be greater than or equal to _startTime
        require(_endTime >= _startTime);
    
        // _salletWallet must be valid
        require(_saleWallet != address(0));

        truToken = TruReputationToken(_token);
        multiSigWallet = _saleWallet;
        saleStartTime = _startTime;
        saleEndTime = _endTime;
    }

    /// @notice Private function used to execute the purchase of Tokens in this sale
    function buyTokens(address _purchaser) private {
        uint256 weiTotal = msg.value;

        // If the Total wei is less than the minimum purchase, reject
        require(weiTotal >= MIN_AMOUNT);

        // If the Total wei is greater than the maximum stake, purchasers must be on the whitelist
        if (weiTotal > MAX_AMOUNT) {
            require(purchaserWhiteList[msg.sender]); 
        }
    
        // Prevention to stop circumvention of Maximum Amount without being on the Whitelist
        if (purchasedAmount[msg.sender] != 0 && !purchaserWhiteList[msg.sender]) {
            uint256 totalPurchased = purchasedAmount[msg.sender];
            totalPurchased = totalPurchased.add(weiTotal);
            require(totalPurchased < MAX_AMOUNT);
        }

        uint256 tokenRate = BASE_RATE;
    
        if (isPreSale) {
            tokenRate = PRESALE_RATE;
        }
        if (isCrowdSale) {
            tokenRate = SALE_RATE;
        }

        // Multiply Wei x Rate to get Number of Tokens to create (as a 10^18 subunit)
        uint256 noOfTokens = weiTotal.mul(tokenRate);
    
        // Add the wei to the running total
        weiRaised = weiRaised.add(weiTotal);

        // If the purchaser address has not purchased already, add them to the list
        if (purchasedAmount[msg.sender] == 0) {
            purchaserCount++;
        }
        soldTokens = soldTokens.add(noOfTokens);

        purchasedAmount[msg.sender] = purchasedAmount[msg.sender].add(msg.value);
        tokenAmount[msg.sender] = tokenAmount[msg.sender].add(noOfTokens);

        // Mint the Tokens to the Purchaser
        truToken.mint(_purchaser, noOfTokens);
        TokenPurchased(msg.sender,
        _purchaser,
        weiTotal,
        noOfTokens);
        forwardFunds();
    }
}