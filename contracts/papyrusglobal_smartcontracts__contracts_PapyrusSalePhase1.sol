pragma solidity ^0.4.11;

/* COMMENTED OUT FOR NOW

import "./PrePapyrusToken.sol";

/// @title Papyrus Sale Phase 1 dutch auction contract.
contract PapyrusSalePhase1 is Ownable {
    using SafeMath for uint256;

    // TYPES

    enum Stage {
        JustCreated,        // Contract is just created
        AuctionDeployed,    // Auction is just deployed but not set up yet
        AuctionSetUp,       // Auction is set up and ready to start
        AuctionStarted,     // Auction is started and bids can be received by contract
        AuctionFinishing,   // Auction is still continuing but price is fixed now
        AuctionFinished,    // Auction is finished so no bids can be received by contract
        ClaimingStarted     // Auction is finished and claiming/exchanging tokens can be done
    }

    // EVENTS

    event BidReceived(address indexed sender, uint256 amount, uint128 customerId);
    event BidAccepted(address indexed sender, uint256 amount, uint128 customerId);
    event TokensClaimed(address indexed sender, uint256 amount, uint128 customerId);
    event TokensExchanged(address indexed sender, uint256 amount, uint128 customerId);

    // PUBLIC FUNCTIONS

    /// @dev Contract constructor function.
    /// @param _prePapyrusToken Pre-Papyrus token contract address (it also contains info about pre-sale).
    /// @param _wallet Papyrus multisignature wallet address for storing ETH after claiming.
    function PapyrusSalePhase1(address _prePapyrusToken, address _wallet) {
        require(_prePapyrusToken != address(0) && _wallet != address(0));
        prePapyrusToken = PrePapyrusToken(_prePapyrusToken);
        kycManager = prePapyrusToken.kycManager();
        wallet = _wallet;
        stage = Stage.JustCreated;
    }

    /// @dev Callback function just calls bid() function.
    function() payable {
        bid(msg.sender, 0);
    }

    /// @dev Deploy function sets Papyrus token contract address and amount of selling tokens.
    /// @param _papyrusToken Papyrus token contract address.
    /// @param _tokensToSell Amount of tokens expected to be sold during auction.
    function deploy(address _papyrusToken, uint256 _tokensToSell)
        onlyOwner
        atStage(Stage.JustCreated)
    {
        require(_papyrusToken != address(0) && _tokensToSell != 0);
        papyrusToken = BasicToken(_papyrusToken);
        require(papyrusToken.balanceOf(this) >= tokensToSell);
        tokensToSell = _tokensToSell;
        stage = Stage.AuctionDeployed;
    }

    /// @dev Changes auction settings before auction is started.
    /// @param _ceiling Maximum amount of weis expected to receive during auction.
    /// @param _priceEther Current price ETH/USD.
    /// @param _priceTokenMin Minimum allowed price for Papyrus token.
    /// @param _priceTokenMax Maximum allowed price for Papyrus token.
    /// @param _priceCurveFactor This value used as denominator during calculating token price and allows to manage curve behavior during auction.
    /// @param _bonusPercent Percent of bonus (in USD) Papyrus tokens we share with Pre-Papyrus token holders during exchange.
    /// @param _minBid Minimum amount of weis for participants of the auction.
    /// @param _auctionPeriod Period of time when auction will be available after stop price is achieved (in seconds).
    /// @param _auctionStart Index of block from which public auction should be started.
    /// @param _auctionClaimingStart Index of block from which claiming should be started.
    function setup(
        uint256 _ceiling,
        uint256 _priceEther,
        uint256 _priceTokenMin,
        uint256 _priceTokenMax,
        uint256 _priceCurveFactor,
        uint8   _bonusPercent,
        uint256 _minBid,
        uint256 _auctionPeriod,
        uint256 _auctionStart,
        uint256 _auctionClaimingStart
    )
        onlyOwner
    {
        require(stage == Stage.AuctionDeployed || stage == Stage.AuctionSetUp);
        require(_ceiling != 0 && _priceEther != 0 && _priceTokenMin != 0 && _priceTokenMin < _priceTokenMax && _priceCurveFactor != 0);
        require(_auctionPeriod != 0 && block.number < _auctionStart && _auctionStart <= _auctionClaimingStart);
        ceiling = _ceiling;
        priceEther = _priceEther;
        priceTokenMin = _priceTokenMin;
        priceTokenMax = _priceTokenMax;
        priceCurveFactor = _priceCurveFactor;
        bonusPercent = _bonusPercent;
        minBid = _minBid;
        auctionPeriod = _auctionPeriod;
        auctionStart = _auctionStart;
        auctionClaimingStart = _auctionClaimingStart;
        stage = Stage.AuctionSetUp;
    }

    /// @dev Sets auction start block index.
    function setAuctionStart(uint256 _blockIndex)
        onlyOwner
        timedTransitions
    {
        require(stage == Stage.AuctionSetUp);
        require(_blockIndex > block.number && _blockIndex <= auctionClaimingStart);
        auctionStart = _blockIndex;
    }

    /// @dev Sets tokens claiming start block index.
    function setClaimingStart(uint256 _blockIndex)
        onlyOwner
        timedTransitions
    {
        require(stage >= Stage.AuctionSetUp && stage < Stage.ClaimingStarted);
        require(_blockIndex > block.number && _blockIndex >= auctionStart);
        auctionClaimingStart = _blockIndex;
    }

    /// @dev Sets ether price in USD.
    /// @param _priceEther Current price ETH/USD.
    function setPriceEther(uint256 _priceEther)
        onlyOwner
        timedTransitions
    {
        require(stage >= Stage.AuctionSetUp && stage < Stage.ClaimingStarted);
        require(_priceEther != 0);
        priceEther = _priceEther;
    }

    /// @dev Calculates current token price.
    /// @return Returns token price.
    function calcCurrentTokenPrice()
        timedTransitions
        returns (uint256)
    {
        return stage >= Stage.AuctionFinishing ? finalPrice : calcTokenPrice();
    }

    /// @dev Returns correct stage, even if a function with timedTransitions modifier has not been called yet.
    /// @return Returns current auction stage.
    function updateStage()
        timedTransitions
        returns (Stage)
    {
        return stage;
    }

    /// @dev Allows to send a bid to the auction.
    /// @param receiver Bid will be assigned to this address if set.
    /// @param customerId (optional) UUID v4 to track the successful payments on the server side.
    function bid(address receiver, uint128 customerId)
        payable
        isValidPayload
        timedTransitions
        returns (uint256 amount)
    {
        require(stage >= Stage.AuctionStarted && stage < Stage.AuctionFinished);
        require(msg.value > 0 && msg.value >= minBid);
        if (receiver == address(0))
            receiver = msg.sender;
        amount = msg.value;
        uint256 tokenPrice = calcTokenPrice();
        uint256 amountAllowed = calcAllowedWeisToInvest(tokenPrice);
        if (amountAllowed == 0) {
            // When amountAllowed is equal to zero the auction is ended and finalizeAuction is triggered.
            finalizeAuction();
        }
        // Only invest allowed amount
        if (amount > amountAllowed) {
            amount = amountAllowed;
            // Send change back to receiver address. In case of a ShapeShift bid the user receives the change back directly.
            if (!receiver.send(msg.value.sub(amount))) {
                // Sending failed
                revert();
            }
        }
        if (amount == 0)
            return;
        // Forward funding to ether wallet
        if (!wallet.send(amount)) {
            // Sending failed
            revert();
        }
        if (receivedBids[receiver] == 0) {
            participants.push(receiver);
            ++participantCount;
        }
        receivedBids[receiver] = receivedBids[receiver].add(amount);
        kycManager.setKycRequirement(receiver, true);
        totalReceived = totalReceived.add(amount);
        if (amountAllowed == amount) {
            // When amountAllowed is equal to the amount the auction is ended and finalizeAuction is triggered.
            finalizeAuction();
        }
        BidReceived(receiver, amount, customerId);
    }

    /// @dev Claims tokens for bidder after auction.
    /// @param receiver Tokens will be assigned to this address if set.
    /// @param customerId (optional) UUID v4 to track the successful claiming on the server side.
    function claim(address receiver, uint128 customerId)
        isValidPayload
        timedTransitions
        atStage(Stage.ClaimingStarted)
    {
        if (receiver == address(0))
            receiver = msg.sender;
        uint256 amountWeis = receivedBids[receiver].sub(acceptedBids[receiver]);
        require(amountWeis > 0);
        require(!kycManager.isKycRequired(receiver));
        uint256 amountTokens = amountWeis.mul(finalPrice).div(E18);
        if (!papyrusToken.transfer(receiver, amountTokens)) {
            // Sending failed
            revert();
        }
        acceptedBids[receiver] = acceptedBids[receiver].add(amountWeis);
        BidAccepted(receiver, amountWeis, customerId);
        TokensClaimed(receiver, amountTokens, customerId);
    }

    /// @dev Exchanges PRP tokens to PPR tokens.
    /// @param receiver PPR tokens will be assigned to this address if set.
    /// @param customerId (optional) UUID v4 to track the successful claiming on the server side.
    function exchange(address receiver, uint128 customerId)
        isValidPayload
        timedTransitions
        atStage(Stage.ClaimingStarted)
    {
        if (receiver == address(0))
            receiver = msg.sender;
        uint256 receiverBalance = prePapyrusToken.balanceOf(receiver);
        require(receiverBalance > 0);
        require(!kycManager.isKycRequired(receiver));
        uint256 amountTokens = calcReservedTokens(receiverBalance, finalPrice);
        if (!papyrusToken.transfer(receiver, amountTokens)) {
            // Sending failed
            revert();
        }
        prePapyrusToken.burn(receiver, receiverBalance);
        TokensExchanged(receiver, amountTokens, customerId);
    }

    /// @dev Calculates token price.
    /// @return Returns token price in weis.
    function calcTokenPrice() constant public returns (uint256) {
        uint256 priceFactor = calcTokenPriceFactor();
        return calcPriceFromFactor(priceFactor);
    }

    /// @dev Calculates token price factor.
    /// @return Returns token price factor in range [0; 10**18].
    function calcTokenPriceFactor() constant public returns (uint256) {
        uint256 denominator = (stage >= Stage.AuctionStarted ? block.number - auctionStart : 0) + priceCurveFactor;
        return priceCurveFactor.mul(E18).div(denominator).add(1);
    }

    /// @dev Calculates stop price.
    /// @return Returns stop price in weis.
    function calcStopPrice() constant public returns (uint256) {
        uint256 priceFactor = calcStopPriceFactor();
        return calcPriceFromFactor(priceFactor);
    }

    /// @dev Calculates stop price factor.
    /// @return Returns stop price factor in range [0; 10**18].
    function calcStopPriceFactor() constant public returns (uint256) {
        return totalReceived.mul(E18).div(ceiling).add(1);
    }

    // PRIVATE FUNCTIONS

    function finalizeAuction() private {
        bool achieved = totalReceived == ceiling;
        stage = achieved ? Stage.AuctionFinished : Stage.AuctionFinishing;
        finalPrice = achieved ? calcTokenPrice() : calcStopPrice();
        uint256 allowedWeis = calcAllowedWeisToInvest(finalPrice);
        if (allowedWeis == 0) {
        }
        uint256 reservedTokens = calcReservedTokens(prePapyrusToken.tokensSold(), finalPrice);
        uint256 tokensSold = totalReceived.mul(E18).div(finalPrice).add(reservedTokens);
        if (tokensSold > tokensToSell) {
            // It looks like finalPrice is too low so we have no enough tokens to guarantee all claims/exchanges
            // To workaround this make finalPrice a bit higher (it still will be equal or lower than token price for last bidder)
            uint256 weisForTokens = tokensSold.mul(finalPrice).div(E18);
            finalPrice = weisForTokens.mul(E18).div(tokensToSell);
            reservedTokens = calcReservedTokens(prePapyrusToken.tokensSold(), finalPrice);
            tokensSold = totalReceived.mul(E18).div(finalPrice).add(reservedTokens);
        }
        if (tokensSold < tokensToSell) {
            // Auction contract transfers all unsold tokens to Papyrus inventory multisig
            papyrusToken.transfer(wallet, tokensToSell.sub(tokensSold));
        }
        finishingTime = now;
    }

    function calcPriceFromFactor(uint256 factor) constant private returns (uint256) {
        return priceTokenMin.add(priceTokenMax.sub(priceTokenMin).mul(factor).div(E18));
    }

    function calcReservedTokens(uint256 tokenAmount, uint256 tokenPrice) constant private returns (uint256) {
        uint256 prePapyrusTokensSoldEth = tokenAmount.mul(prePapyrusToken.priceToken()).div(E18);
        uint256 pruPapyrusTokensSoldUsd = prePapyrusTokensSoldEth.mul(prePapyrusToken.priceEther()).div(E18);
        uint256 reservedUsd = pruPapyrusTokensSoldUsd.mul(100 + bonusPercent).div(100);
        uint256 reservedEth = reservedUsd.mul(E18).div(priceEther);
        uint256 reservedTokens = reservedEth.mul(E18).div(tokenPrice);
        return reservedTokens;
    }

    function calcAllowedWeisToInvest(uint256 tokenPrice) constant private returns (uint256) {
        // First of all calculate amount of tokens needed to perform exchanging for pre-sale participators
        uint256 reservedTokens = calcReservedTokens(prePapyrusToken.tokensSold(), tokenPrice);
        if (reservedTokens >= tokensToSell)
            return 0;
        // Prevent that more than available tokens amount is sold
        uint256 amountTotal = tokensToSell.sub(reservedTokens).mul(tokenPrice).div(E18);
        if (totalReceived >= amountTotal)
            return 0;
        uint256 amountAllowed = amountTotal.sub(totalReceived);
        uint256 maxAmountBasedOnTotalReceived = ceiling.sub(totalReceived);
        if (maxAmountBasedOnTotalReceived < amountAllowed)
            amountAllowed = maxAmountBasedOnTotalReceived;
        return amountAllowed;
    }

    // MODIFIERS

    modifier atStage(Stage _stage) {
        require(stage == _stage);
        _;
    }

    modifier isValidPayload() {
        // TODO: Why is this necessary?
        //require(msg.data.length == 4 || msg.data.length == 36);
        _;
    }

    modifier timedTransitions() {
        if (stage == Stage.AuctionSetUp && block.number >= auctionStart)
            stage = Stage.AuctionStarted;
        if (stage == Stage.AuctionStarted && calcTokenPriceFactor() <= calcStopPriceFactor())
            finalizeAuction();
        if (stage == Stage.AuctionFinishing && now > finishingTime + auctionPeriod)
            stage = Stage.AuctionFinished;
        if (stage == Stage.AuctionFinished && block.number >= auctionClaimingStart)
            stage = Stage.ClaimingStarted;
        _;
    }

    // FIELDS

    // Address to Papyrus KYC manager contract
    PapyrusKYC public kycManager;

    // Pre-Papyrus token contract that also contains info about pre-sale
    PrePapyrusToken public prePapyrusToken;

    // Papyrus token contract that should be sold during auction
    BasicToken public papyrusToken;

    // Amount of tokens expected to be sold during whole auction
    uint256 public tokensToSell;

    // Percent of bonus (in USD) Papyrus tokens we share with Pre-Papyrus token holders during exchange
    uint8   public bonusPercent;

    // Address of multisig wallet used to hold received ether
    address public wallet;

    // Auction ceiling in weis
    uint256 public ceiling;

    // Price ETH/USD at the start of auction
    uint256 public priceEther;

    // Minimum allowed price for Papyrus token
    uint256 public priceTokenMin;

    // Maximum allowed price for Papyrus token
    uint256 public priceTokenMax;

    // This value used as denominator during calculating token price and allows to manage curve behavior during auction
    uint256 public priceCurveFactor;

    // Minimal amount of weis for participants of the auction to bid
    uint256 public minBid;

    // Period of time which auction will be available after stop price is achieved
    uint256 public auctionPeriod;

    // Index of block from which auction should be started
    uint256 public auctionStart;

    // Index of block from which claiming should be started
    uint256 public auctionClaimingStart;

    // Timestamp when auction starting finishing (stop price achieved)
    uint256 public finishingTime;

    // Amount of total received weis
    uint256 public totalReceived;

    // Final token price used when auction is ended
    uint256 public finalPrice;

    // List of addresses of all participants of the auction
    address[] public participants;
    
    // Count of all participants of the auction
    uint256 public participantCount;

    // Received bids
    mapping(address => uint256) public receivedBids;

    // Accepted bids
    mapping(address => uint256) public acceptedBids;

    // Current stage of the auction
    Stage public stage;

    // Some pre-calculated constant values
    uint256 private constant E18 = 10**18;
}

*/
