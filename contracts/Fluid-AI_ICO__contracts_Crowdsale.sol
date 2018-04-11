pragma solidity 0.4.21;

// Replace this for the actual code when deploying to the blockchain
import './Drops.sol';

/// @title The ICO contract that will be used to sell the Presale & ICO tokens
/// @author Merunas Grincalaitis <merunasgrincalaitis@gmail.com>
contract Crowdsale is Pausable {
   using SafeMath for uint256;

   // The possible States of the ICO
   enum States {
      NotStarted,
      Round1,
      Round2,
      Round3,
      Round4,
      Ended
   }

   States public currentState = States.NotStarted;
   Drops public token;

   // The rates will be set automatically when you execute setRates() with the price per ether sent as a parameter
   uint256 public round1Rate;
   uint256 public round2Rate;
   uint256 public round3Rate;
   uint256 public round4Rate;
   uint256 public ICOStartTime;
   uint256 public ICOEndTime;

   // How many tokens we want to raise
   uint256 public limitRound1Contribution = 10e24;
   uint256 public limitRound2Contribution = 20e24;
   uint256 public limitRound3Contribution = 32e24;
   uint256 public limitRound4Contribution = 44.5e24;

   // How many tokens we want to raise on the ICO
   uint256 public limitICOContribution = 44.5e24;
   address public wallet;
   uint256 public weiRaised;
   uint256 public tokensSold;
   uint256 public numberOfTransactions;

   // How much each user paid
   mapping(address => uint256) public ICOBalances;

   // How many tokens each user got
   mapping(address => uint256) public tokenBalances;

   // To indicate who purchased what amount of tokens and who received what amount of wei
   event TokenPurchase(address indexed buyer, uint256 value, uint256 amountOfTokens);

   // Events
   event Round1Started();
   event Round2Started();
   event Round3Started();
   event Round4Started();
   event ICOFinalized();

   /// @notice Constructor of the crowsale to set up the main variables and create a token
   /// @param _wallet The wallet address that stores the Wei raised
   /// @param _tokenAddress The token used for the ICO
   /// @param _ICOStartTime When the ICO should start. If it's 0, we'll use
   /// the default value of the variable set above
   /// @param _ICOEndTime When the ICO should end. If it's 0, we'll use the
   /// default value of the variable
   function Crowdsale(
      address _wallet,
      address _tokenAddress,
      uint256 _ICOStartTime,
      uint256 _ICOEndTime
   ) public {
      require(_wallet != address(0));
      require(_tokenAddress != address(0));
      require(_ICOStartTime < _ICOEndTime);

      ICOStartTime = _ICOStartTime;
      ICOEndTime = _ICOEndTime;
      wallet = _wallet;
      token = Drops(_tokenAddress);
   }

   /// @notice The fallback function to buy tokens depending on the States of the
   /// Smart Contract. It reverts if the States is not a valid one to refund the
   /// ether sent to the contract.
   function () public payable {
      updateState();

      if(currentState != States.NotStarted && currentState != States.Ended)
        buyICOTokens();
   }

   /// @notice To buy ICO tokens with the ICO rate
   function buyICOTokens() internal whenNotPaused {
      require(validICOPurchase());

      uint256 tokens = 0;
      uint256 amountPaid = calculateExcessBalance();

      if(tokensSold < limitRound1Contribution) {
         // Tier 1
         tokens = amountPaid.mul(round1Rate);
         // If the amount of tokens that you want to buy gets out of this tier
         if(tokensSold.add(tokens) > limitRound1Contribution)
            tokens = calculateExcessTokens(amountPaid, limitRound1Contribution, 1, round1Rate);
      } else if(tokensSold >= limitRound1Contribution && tokensSold < limitRound2Contribution) {
         // Tier 2
         tokens = amountPaid.mul(round2Rate);
         if(tokensSold.add(tokens) > limitRound2Contribution)
            tokens = calculateExcessTokens(amountPaid, limitRound2Contribution, 2, round2Rate);
      } else if(tokensSold >= limitRound2Contribution && tokensSold < limitRound3Contribution) {
         // Tier 3
         tokens = amountPaid.mul(round3Rate);
         if(tokensSold.add(tokens) > limitRound3Contribution)
            tokens = calculateExcessTokens(amountPaid, limitRound3Contribution, 3, round3Rate);
      } else if(tokensSold >= limitRound3Contribution) {
         // Tier 4
         tokens = amountPaid.mul(round4Rate);
      }

      weiRaised = weiRaised.add(amountPaid);
      tokensSold = tokensSold.add(tokens);

      // Keep a record of how many tokens everybody gets in case we need to do refunds
      tokenBalances[msg.sender] = tokenBalances[msg.sender].add(tokens);
      ICOBalances[msg.sender] = ICOBalances[msg.sender].add(amountPaid);
      emit TokenPurchase(msg.sender, amountPaid, tokens);
      numberOfTransactions = numberOfTransactions.add(1);
      // Send the tokens by executing the function from the token contract
      token.distributeTokens(msg.sender, tokens);

      wallet.transfer(amountPaid);
   }

   /// @notice To set the rates for the presale and ICO by the owner before starting
   /// @param _pricePerEtherWithoutDecimals The rate of the presale
   function setRates(uint256 _pricePerEtherWithoutDecimals) public onlyOwner {
      require(_pricePerEtherWithoutDecimals > 0);

      round1Rate = _pricePerEtherWithoutDecimals * 100 / 4; // $0.04
      round2Rate = _pricePerEtherWithoutDecimals * 100 / 20; // $0.20;
      round3Rate = _pricePerEtherWithoutDecimals * 100 / 50; // $0.50;
      round4Rate = _pricePerEtherWithoutDecimals * 100 / 80; // $0.80;
   }

   /// @notice Updates the States of the Contract depending on the time and States.
   /// After updating the state, the code it's execute again in case you jump from 2 states
   /// or similar
   function updateState() public {
      if(currentState == States.Ended) return revert();

      // End the ICO when the time is over or the maximum amount of tokens has been sold
      if(now >= ICOEndTime || tokensSold >= limitICOContribution) {
         currentState = States.Ended;
         emit ICOFinalized();
      } else if(currentState == States.Round3 && tokensSold >= limitRound3Contribution) {
         currentState = States.Round4;
         emit Round4Started();
      } else if(currentState == States.Round2 && tokensSold >= limitRound2Contribution) {
         currentState = States.Round3;
         emit Round3Started();
      } else if(currentState == States.Round1 && tokensSold >= limitRound1Contribution) {
         currentState = States.Round2;
         emit Round2Started();
      } else if(currentState == States.NotStarted && now >= ICOStartTime) {
         currentState = States.Round1;
         emit Round1Started();
      }
   }

   /// @notice Calculates how many ether will be used to generate the tokens in
   /// case the buyer sends more than the maximum balance but has some balance left
   /// and updates the balance of that buyer.
   /// For instance if he's 500 balance and he sends 1000, it will return 500
   /// and refund the other 500 ether
   function calculateExcessBalance() internal whenNotPaused returns(uint256) {
      uint256 amountPaid = msg.value;
      uint256 differenceWei = 0;

      // If we're in the last tier, check that the limit hasn't been reached
      // and if so, refund the difference and return what will be used to
      // buy the remaining tokens
      if(tokensSold >= limitRound3Contribution) {
         uint256 addedTokens = tokensSold.add(amountPaid.mul(round4Rate));
         // If tokensSold + what you paid converted to tokens is bigger than the max
         if(addedTokens > limitICOContribution) {
            // Refund the difference
            uint256 difference = addedTokens.sub(limitICOContribution);
            differenceWei = difference.div(round4Rate);
            amountPaid = amountPaid.sub(differenceWei);
            msg.sender.transfer(differenceWei);
         }
      }

      return amountPaid;
   }

   /// @notice Buys the tokens for the specified tier and for the next one
   /// @param amount The amount of ether paid to buy the tokens
   /// @param tokensThisTier The limit of tokens of that tier
   /// @param tierSelected The tier selected
   /// @param _rate The rate used for that `tierSelected`
   /// @return uint The total amount of tokens bought combining the tier prices
   function calculateExcessTokens(
      uint256 amount,
      uint256 tokensThisTier,
      uint256 tierSelected,
      uint256 _rate
   ) public returns(uint256 totalTokens) {
      require(amount > 0 && tokensThisTier > 0 && _rate > 0);
      require(tierSelected >= 1 && tierSelected <= 4);

      uint weiThisTier = tokensThisTier.sub(tokensSold).div(_rate);
      uint weiNextTier = amount.sub(weiThisTier);
      uint tokensNextTier = 0;

      // If there's excessive wei for the last tier, refund those
      if(tierSelected != 4)
         tokensNextTier = calculateTokensTier(weiNextTier, tierSelected.add(1));
      else
         msg.sender.transfer(weiNextTier);

      totalTokens = tokensThisTier.sub(tokensSold).add(tokensNextTier);
   }

   function calculateTokensTier(uint256 weiPaid, uint256 tierSelected)
        internal constant returns(uint256 calculatedTokens)
   {
      require(weiPaid > 0);
      require(tierSelected >= 1 && tierSelected <= 4);

      if(tierSelected == 1)
         calculatedTokens = weiPaid.mul(round1Rate);
      else if(tierSelected == 2)
         calculatedTokens = weiPaid.mul(round2Rate);
      else if(tierSelected == 3)
         calculatedTokens = weiPaid.mul(round3Rate);
      else
         calculatedTokens = weiPaid.mul(round4Rate);
   }

   /// @notice To get the current States as a string
   function getStates() public constant returns(string) {
      if(currentState == States.NotStarted)
         return 'not started';
     else if(currentState == States.Round1)
        return 'round 1';
      else if(currentState == States.Round2)
         return 'round 2';
      else if(currentState == States.Round3)
         return 'round 3';
      else if(currentState == States.Round4)
         return 'round 4';
      else if(currentState == States.Ended)
         return 'ico ended';
   }

   /// @notice To verify that the purchase of ICO tokens is valid
   function validICOPurchase() internal constant returns(bool) {
      bool withinTime = now >= ICOStartTime && now < ICOEndTime;
      bool atLimit = tokensSold < limitICOContribution;

      return withinTime && atLimit;
   }

   function emergencyExtract() public onlyOwner {
       owner.transfer(this.balance);
   }
}
