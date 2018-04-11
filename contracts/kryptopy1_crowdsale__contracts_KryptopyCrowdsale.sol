pragma solidity ^0.4.15;

import "./KryptopyToken.sol";
import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol";


/**
 * @title KryptopyCrowdsale
 * @dev This is a fully fledged crowdsale.
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this crowdsale we are providing following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 * RefundableCrowdsale - set a min goal to be reached and returns funds if it's not met
 *
 * After adding multiple features it's good practice to run integration tests
 * to ensure that subcontracts works together as intended.
 */
contract KryptopyCrowdsale is CappedCrowdsale, RefundableCrowdsale {

    /*
    *  Events
    */
    event PreICOStarted();
    event PreICOSucceeded();
    event PreICOFailed();
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    /*
    *  Constants
    */
    /*
     * - Preparing: All contract initialization calls and variables have not been set yet
     * - Prefunding: We have not passed start time yet
     * - Funding: Active crowdsale
     * - Success: Minimum funding goal reached
     * - Failure: Minimum funding goal not reached before ending time
     * - Finalized: The finalized has been called and succesfully executed
     * - Refunding: Refunds are loaded on the contract for reclaim.
     */
    enum CrowdsaleProgress {
      PREICO,
      GOALSUCCESS,
      GOALFAILED
    }

    /*
    *  Storage
    */
    // the amount of WEI to remove at each step of the ICO from the Bonuses
    uint256 public preIcoMin = 400000000000000000 wei;
    // the amount of WEI to remove at each step of the ICO from the Bonuses
    uint256 public preIcoMax = 10000000000000000000 wei;
    // we do not want the contract to start before the start date we put Stopped as initial State to prevent that.
    CrowdsaleProgress public crowdsaleProgress;
    // amount of kpy sent
    uint256 public kpySent;

    /*
    * Public functions
    */
    /** Constructor to initialize all variables, including Crowdsale variables
    * @param _startBlock unix timestamp for start of ICO
    * @param _endBlock unix timestamp for end of ICO
    * @param _rate of ether to KrytopyToken in wei
    * @param _goal minimum amount of funds to be raised in wei
    * @param _cap max amount of funds to be raised in wei
    * @param _wallet Address of the deployed Multisig wallet
    */
    function KryptopyCrowdsale(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _rate,
        uint256 _goal,
        uint256 _cap,
        address _wallet
      )
      CappedCrowdsale(_cap)
      FinalizableCrowdsale()
      RefundableCrowdsale(_goal)
      Crowdsale(_startBlock, _endBlock, _rate, _wallet)
    {
        //As goal needs to be met for a successful crowdsale
        //the value needs to less or equal than a cap which is limit for accepted funds
        require(_goal <= _cap);
        startPreICO();
    }

    // overridden : Crowdsale.buyTokens(address beneficiary) payable
    function buyTokens(address beneficiary)
      public
      payable
    {
        require(beneficiary != 0x0);
        require(validPurchase());
        require(msg.value >= preIcoMin);
        require(msg.value <= preIcoMax);

        uint256 weiAmount = msg.value;

        uint256 exchangeBuffer = 1000000000;
        uint256 tokensToSend = weiAmount.mul(rate).div(exchangeBuffer);

        weiRaised = weiRaised.add(weiAmount);

        // update state
        token.mint(beneficiary, tokensToSend);
        TokenPurchase(
            msg.sender,
            beneficiary,
            weiAmount,
            tokensToSend
        );

        kpySent = kpySent.add(tokensToSend);
        if (kpyGoalReached()) {
            crowdsaleProgress = CrowdsaleProgress.GOALSUCCESS;
            PreICOSucceeded();
        }

        super.forwardFunds();
    }

    /*
    * Internal functions
    */
    // overridden : Crowdsale.createTokenContract()
    function createTokenContract()
      internal
      returns (MintableToken)
    {
        return new KryptopyToken();
    }

    function startPreICO()
      onlyOwner
      internal
    {
        crowdsaleProgress = CrowdsaleProgress.PREICO;
        PreICOStarted();
    }

    function kpyGoalReached()
      internal
      constant
      returns (bool)
    {
        uint256 kpyGoal = 2500000000000000000000;
        return kpySent >= kpyGoal;
    }
}
