pragma solidity ^0.4.14;

/*
    Copyright 2017, Ilana Fraines TokenAi
    With heavy influence from District0xContribution.sol and AragonDev

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import "./SafeMath.sol";
import "./TokenAiNetworkToken.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./HasNoTokens.sol";
import "./interface/TokenController.sol";

contract TokenAiContribution is Pausable, HasNoTokens, TokenController {
    using SafeMath for uint;

    TokenAiNetworkToken public tokenAiNetworkToken;
    address public multisigWallet;                                      // Wallet that receives all sale funds
    address public givethWallet;                                        // Giveth team Wallet that receives funds sent before sale start time
    address public founder1;                                            // Wallet of founder 1
    address public founder2;                                            // Wallet of founder 2
    address public founder3;                                            // Wallet of founder 3
    address public founder4;                                            // Wallet of founder 4
    address public founder5;                                            // Wallet of founder 5

    uint public constant FOUNDER1_STAKE =  11000000000000000000000;                       //wei
    uint public constant FOUNDER2_STAKE =  11000000000000000000000;                       //wei
    uint public constant FOUNDER3_STAKE = 9167000000000000000000;                         //wei
    uint public constant FOUNDER4_STAKE = 3667000000000000000000;                         //wei
    uint public constant FOUNDER5_STAKE = 3667000000000000000000;                         //wei

    uint public constant RESERVE = 4400000000000000000000;                                //wei
    uint public constant CONTRIB_PERIOD1_STAKE = 183334000000000000000000;                //wei
    uint public minContribAmount = 0.01 ether;                                            // 0.01 ether

    uint public constant TEAM_VESTING_CLIFF = 24 weeks;                 // 6 months vesting cliff for founders and advisors, except community advisors
    uint public constant TEAM_VESTING_PERIOD = 96 weeks;                // 2 years vesting period for founders and advisors, except community advisors

    bool public tokenTransfersEnabled = false;                          // TAI token transfers will be enabled manually
                                                                        // after contribution period
                                                                        // Can't be disabled back
    uint public initialPrice = 150;                                     // Number of TAI tokens for 1 eth, at the start of the sale
    uint public finalPrice = 120;                                       // Number of TAI tokens for 1 eth, at the end of the sale
    uint public bonusPrice = 100;                                       // Number of TAI tokens for 1 eth, in the 24hr bonus sale

    uint public priceStages = 4;                                        // Number of different price stages for interpolating between initialPrice and finalPrice

    struct Contributor {
        uint amount;                                                    // Amount of ETH contributed by an address in given contribution period
        uint price;                                                     // price qualified
        bool isCompensated;                                             // Whether this contributor received TAI token for ETH contribution
        uint amountCompensated;                                         // Amount of TAI received. Not really needed to store,
                                                                        // but stored for accounting and security purposes
    }
    uint public initialSupply;                                          // Number of TAI tokens generated
    uint public softCapAmount;                                          // Soft cap of contribution period in wei
    uint public afterSoftCapDuration;                                   // Number of seconds to the end of sale from the moment of reaching soft cap (unless reaching hardcap)
    uint public hardCapAmount;                                          // When reached this amount of wei, the contribution will end instantly
    uint public startTime;                                              // Start time of contribution period in UNIX time
    uint public endTime;                                                // End time of contribution period in UNIX time
    bool public isEnabled;                                              // If contribution period was enabled by multisignature
    bool public softCapReached;                                         // If soft cap was reached
    bool public hardCapReached;                                         // If hard cap was reached
    uint public totalContributed;                                       // Total amount of wei contributed in given period
    address[] public contributorsKeys;                                  // Addresses of all contributors in given contribution period
    mapping (address => Contributor) public contributors;

    event onContribution(uint totalContributed1, address indexed contributor, uint amount,
        uint contributorsCount);
    event onSoftCapReached(uint endTime1);
    event onHardCapReached(uint endTime1);
    event onCompensated(address indexed contributor, uint amount);
    event onPreContributionEvent(address indexed contributor, uint amount, uint price);

    modifier nonZeroAddress(address x) {
        require (x != 0);
        _;
    }

    modifier onlyBeforeEvent {
      require (now < startTime && !isEnabled );
      _;
    }

    function TokenAiContribution(
        address _multisigWallet,
        address _givethWallet,
        address _founder1,
        address _founder2,
        address _founder3,
        address _founder4,
        address _founder5
    ) {
        multisigWallet = _multisigWallet;
        givethWallet = _givethWallet;
        founder1 = _founder1;
        founder2 = _founder2;
        founder3 = _founder3;
        founder4 = _founder4;
        founder5 = _founder5;
    }

    // @notice Returns true if contribution period is currently running
    function isContribPeriodRunning() constant returns (bool) {
        return isEnabled &&
               startTime <= now &&
               endTime > now;
    }

     function contribute()
        payable
        stopInEmergency
    {
        contributeWithAddress(msg.sender);
    }

    // @notice Function to participate in contribution period
    // Amounts from the same address should be added up
    // If soft or hard cap is reached, end time should be modified
    // Funds should be transferred into multisig wallet
    // @param contributor Address that will receive TAI token
    function contributeWithAddress(address contributor)
        payable
        stopInEmergency
    {
        require(msg.value >= minContribAmount);
        if ( isContribPeriodRunning() ) {
          uint contribValue = msg.value;
          uint excessContribValue = 0;

          uint oldTotalContributed = totalContributed;

          totalContributed = oldTotalContributed.add(contribValue);

          uint newTotalContributed = totalContributed;
          uint price = getPrice(now);
          // Soft cap was reached
          if (newTotalContributed >= softCapAmount &&
              oldTotalContributed < softCapAmount)
          {
              softCapReached = true;
              endTime = afterSoftCapDuration.add(now);
              onSoftCapReached(endTime);
          }
          // Hard cap was reached
          if (newTotalContributed >= hardCapAmount &&
              oldTotalContributed < hardCapAmount)
          {
              hardCapReached = true;
              endTime = now;
              onHardCapReached(endTime);

              // Everything above hard cap will be sent back to contributor
              excessContribValue = newTotalContributed.sub(hardCapAmount);
              contribValue = contribValue.sub(excessContribValue);
              newTotalContributed = newTotalContributed.sub(excessContribValue);

              totalContributed = hardCapAmount;
          }

          if (contributors[contributor].amountCompensated == 0) {
              contributorsKeys.push(contributor);
          }
          contributors[contributor].amountCompensated = contributors[contributor].amountCompensated.add(SafeMath.mul(price,contribValue));
          //transfer contrution to multisigWallet
          multisigWallet.transfer(contribValue);
          if (excessContribValue > 0) {
              msg.sender.transfer(excessContribValue);
          }
          onContribution(newTotalContributed, contributor, (now), contributorsKeys.length);
        } else if(now < startTime) {
          uint contribValue1 = msg.value;
          if (contributors[contributor].amountCompensated == 0) {
              contributorsKeys.push(contributor);
          }
          contributors[contributor].amountCompensated = contributors[contributor].amountCompensated.add(1);
          //transfer contrution to giveth wallet if user tries to contribut in advance of sale
          givethWallet.transfer(contribValue1);
          onContribution(newTotalContributed, contributor, contribValue1, contributorsKeys.length);
        }
    }

    // @notice This method is called by owner after contribution period ends, to distribute TAI based on the stage of purchase and price
    // Each contributor should receive TAI just once even if this method is called multiple times
    // In case of many contributors must be able to compensate contributors in paginational way, otherwise might
    // run out of gas if wanted to compensate all on one method call. Therefore parameters offset and limit
    // @param offset Number of first contributors to skip.
    // @param limit Max number of contributors compensated on this call
    function compensateContributors(uint offset, uint limit)
        onlyOwner
    {
        require(isEnabled);
        require(endTime < now);

        uint i = offset;
        uint compensatedCount = 0;
        uint contributorsCount = contributorsKeys.length;

        while (i < contributorsCount && compensatedCount < limit) {
            address contributorAddress = contributorsKeys[i];
            if (!contributors[contributorAddress].isCompensated) {
                tokenAiNetworkToken.transfer(contributorAddress, contributors[contributorAddress].amountCompensated);
                contributors[contributorAddress].isCompensated = true;
                onCompensated(contributorAddress, contributors[contributorAddress].amountCompensated);

                compensatedCount++;
            }
            i++;
        }
    }

    // @notice TokenAi needs to make initial token allocations for presale partners
    // This allocation has to be made before the sale is activated. Activating the sale means no more
    // arbitrary allocations are possible and expresses conformity.
    // @param contributor: The contributors address.
    // @param weiAmount: Amount of wei contributed.
    // @param taiPerEth: taiPerEth of TAI per eth.
    function allocatePresaleTokens(address contributor, uint weiAmount, uint price)
             onlyBeforeEvent
             nonZeroAddress(contributor)
             onlyOwner
             public {
      require(!softCapReached);
      uint contribValue = weiAmount;
      uint excessContribValue = 0;

      uint oldTotalContributed = totalContributed;

      totalContributed = oldTotalContributed.add(contribValue);

      uint newTotalContributed = totalContributed;
        // Soft cap was reached
      if (newTotalContributed >= softCapAmount &&
                   oldTotalContributed < softCapAmount)
        {
            softCapReached = true;
            onSoftCapReached(1);
            // Everything above soft cap will not be accepted
            excessContribValue = newTotalContributed.sub(softCapAmount);
            contribValue = contribValue.sub(excessContribValue);
            newTotalContributed = newTotalContributed.sub(excessContribValue);

            totalContributed = softCapAmount;

        }

        if (contributors[contributor].amountCompensated == 0) {
            contributorsKeys.push(contributor);
        }
        contributors[contributor].amountCompensated = contributors[contributor].amountCompensated.add(SafeMath.mul(price,contribValue));

        onPreContributionEvent(contributor, contribValue, price);
    }

    // @notice Gets what the price is for a given stage
    // @param stage: Stage number
    // @return price per eth for that stage.
    function priceForStage(uint8 stage) constant internal returns (uint) {
        require (stage < priceStages);
        uint priceDifference = SafeMath.sub(initialPrice, finalPrice);
        uint stageDelta = SafeMath.div(priceDifference, uint(priceStages - 1));
        return SafeMath.sub(initialPrice, SafeMath.mul(stage, stageDelta));
    }
    // @notice Gets what the stage is for a given date and time
    // @param datetime: UNIX time
    // @return The sale stage for that date time. Stage is between 0 and (priceStages - 1)
    function stageForDate(uint dateTime) constant internal returns (uint) {
        uint current = SafeMath.sub(dateTime, startTime);
        uint totalTime = SafeMath.sub(endTime, startTime);

        return SafeMath.div(SafeMath.mul(priceStages, current), totalTime);
    }

    // @notice Get the price for a TAI token at any given date
    // @param dateTime for which the price is requested
    // @return Number of eth-TAI for 1 eth
    // If sale isn't ongoing for that time, returns 0.
    //Last 1/30 the bonus period price
    function getPrice(uint dateTime) constant public returns (uint) {
      if (dateTime < startTime || dateTime >= endTime) return 0;
      uint totalTime = SafeMath.sub(endTime, startTime);
      uint last30th = SafeMath.div(totalTime,30);

      if(dateTime > SafeMath.sub(endTime,last30th)){
        return bonusPrice;
      } else{
          return priceForStage(uint8(stageForDate(dateTime)));
      }
    }

    // @notice Method for setting up contribution period
    // Only owner should be able to execute
    // Setting first contribution period sets up vesting for founders & advisors
    // Contribution period should still not be enabled after calling this method
    // @param softCapAmount Soft Cap in eth
    // @param afterSoftCapDuration Number of seconds till the end of sale in the moment of reaching soft cap (unless reaching hard cap)
    // @param hardCapAmount Hard Cap in eth
    // @param startTime Contribution start time in UNIX time
    // @param endTime Contribution end time in UNIX time
    function setContribPeriod(
        uint _softCapAmount,
        uint _afterSoftCapDuration,
        uint _hardCapAmount,
        uint _startTime,
        uint _endTime
    )
        onlyOwner
    {
        require(_softCapAmount > 0);
        require(_hardCapAmount > _softCapAmount);
        require(_afterSoftCapDuration > 0);
        require(_startTime > now);
        require(_endTime > _startTime);
        require(!isEnabled);

        softCapAmount = _softCapAmount;
        afterSoftCapDuration = _afterSoftCapDuration;
        hardCapAmount = _hardCapAmount;
        startTime = _startTime;
        endTime = _endTime;

       tokenAiNetworkToken.revokeAllTokenGrants(founder1);
       tokenAiNetworkToken.revokeAllTokenGrants(founder2);
       tokenAiNetworkToken.revokeAllTokenGrants(founder3);
       tokenAiNetworkToken.revokeAllTokenGrants(founder4);
       tokenAiNetworkToken.revokeAllTokenGrants(founder5);

        uint64 vestingDate = uint64(startTime.add(TEAM_VESTING_PERIOD));
        uint64 cliffDate = uint64(startTime.add(TEAM_VESTING_CLIFF));
        uint64 startDate = uint64(startTime);

        tokenAiNetworkToken.grantVestedTokens(founder1, SafeMath.mul(FOUNDER1_STAKE,initialPrice), startDate, cliffDate, vestingDate, true, false);
        tokenAiNetworkToken.grantVestedTokens(founder2, SafeMath.mul(FOUNDER2_STAKE,initialPrice), startDate, cliffDate, vestingDate, true, false);
        tokenAiNetworkToken.grantVestedTokens(founder3, SafeMath.mul(FOUNDER3_STAKE,initialPrice), startDate, cliffDate, vestingDate, true, false);
        tokenAiNetworkToken.grantVestedTokens(founder4, SafeMath.mul(FOUNDER4_STAKE,initialPrice), startDate, cliffDate, vestingDate, true, false);
        tokenAiNetworkToken.grantVestedTokens(founder5, SafeMath.mul(FOUNDER5_STAKE,initialPrice), startDate, cliffDate, vestingDate, true, false);

        //transfer reserve tokens to multisig
        uint reserveVal = SafeMath.mul(RESERVE,initialPrice);
        tokenAiNetworkToken.transfer(multisigWallet,reserveVal);
    }

    // @notice Enables contribution period
    // Must be executed by owner
    function enableContribPeriod()
        onlyOwner
    {
        require(startTime > now);
        isEnabled = true;
    }

    // @notice Sets new min. contribution amount
    // Only owner can execute
    // Cannot be executed while contribution period is running
    // @param _minContribAmount new min. amount
    function setMinContribAmount(uint _minContribAmount)
        onlyOwner
    {
        require(_minContribAmount > 0);
        require(startTime > now);
        minContribAmount = _minContribAmount;
    }

    // @notice Sets TokenAiNetworkToken contract
    // Generates all TAI tokens and assigns them to this contract
    // If token contract has already generated tokens, do not generate again
    // @param _tokenAiNetworkToken TokenAiNetworkToken address
    function setTokenAiNetworkToken(address _tokenAiNetworkToken)
        onlyOwner
    {
        require(_tokenAiNetworkToken != 0);
        require(!isEnabled);
        tokenAiNetworkToken = TokenAiNetworkToken(_tokenAiNetworkToken);
        if (tokenAiNetworkToken.totalSupply() == 0) {
          initialSupply = FOUNDER1_STAKE
          .add(FOUNDER2_STAKE)
          .add(FOUNDER3_STAKE)
          .add(FOUNDER4_STAKE)
          .add(FOUNDER5_STAKE)
          .add(RESERVE)
          .add(CONTRIB_PERIOD1_STAKE);

          tokenAiNetworkToken.generateTokens(this,
              SafeMath.mul(initialSupply,initialPrice));

        }
    }

    // Will be executed after contribution period by owner
    function enableTokenAiTransfers()
        onlyOwner
    {
        require(endTime < now);
        tokenTransfersEnabled = true;
    }

    //Burn outstanding tokens owned by contract
    function finalizeContributionEvent()
     onlyOwner
     {
        require(endTime < now);
        tokenAiNetworkToken.destroyTokens(this,tokenAiNetworkToken.balanceOf(this));
        tokenAiNetworkToken.changeController(multisigWallet);

    }
    // @notice Method to claim tokens accidentally sent to a TAI contract
    // Only multisig wallet can execute
    // @param _token Address of claimed ERC20 Token
    function claimTokensFromTokenAiNetworkToken(address _token)
        onlyOwner
    {
        tokenAiNetworkToken.claimTokens(_token, multisigWallet);
    }

    function()
        payable
        stopInEmergency
    {
        contributeWithAddress(msg.sender);
    }

    // MiniMe Controller default settings for allowing token transfers.
    function proxyPayment(address _owner) payable public returns (bool) {
        revert();
    }

    // Before transfers are enabled for everyone, only this contract is allowed to distribute TAI
    function onTransfer(address _from, address _to, uint _amount) public returns (bool) {
        return tokenTransfersEnabled || _from == address(this) || _to == address(this);
    }

    function onApprove(address _owner, address _spender, uint _amount) public returns (bool) {
        return tokenTransfersEnabled;
    }

    function isTokenSaleToken(address tokenAddr) returns(bool) {
        return tokenAiNetworkToken == tokenAddr;
    }

    /*
     Following constant methods are used for tests and contribution web app
     They don't impact logic of contribution contract, therefor DOES NOT NEED TO BE AUDITED
     */

    // Used by contribution front-end to obtain contribution period properties
    function getContribPeriod()
        constant
        returns (bool[3] boolValues, uint[8] uintValues)
    {
        boolValues[0] = isEnabled;
        boolValues[1] = softCapReached;
        boolValues[2] = hardCapReached;

        uintValues[0] = softCapAmount;
        uintValues[1] = afterSoftCapDuration;
        uintValues[2] = hardCapAmount;
        uintValues[3] = startTime;
        uintValues[4] = endTime;
        uintValues[5] = totalContributed;
        uintValues[6] = contributorsKeys.length;
        uintValues[7] = CONTRIB_PERIOD1_STAKE;

        return (boolValues, uintValues);
    }

    // Used by contribution front-end to obtain contribution contract properties
      function getConfiguration()
          constant
          returns (bool, address, address, address, address, address, address, bool)
      {

          return (stopped, multisigWallet, founder1, founder2, founder3, founder4, founder5, tokenTransfersEnabled);
      }

    // Used by contribution front-end to obtain contributor's properties
    function getContributor(address contributorAddress)
        constant
        returns(uint, bool, uint, uint)
    {
        Contributor contributor = contributors[contributorAddress];
        return (contributor.amount, contributor.isCompensated, contributor.amountCompensated , contributor.price);
    }

    // Function to verify if all contributors were compensated
    function getUncompensatedContributors(uint offset, uint limit)
        constant
        returns (uint[] contributorIndexes)
    {
        uint contributorsCount = contributorsKeys.length;

        if (limit == 0) {
            limit = contributorsCount;
        }

        uint i = offset;
        uint resultsCount = 0;
        uint[] memory _contributorIndexes = new uint[](limit);

        while (i < contributorsCount && resultsCount < limit) {
            if (!contributors[contributorsKeys[i]].isCompensated) {
                _contributorIndexes[resultsCount] = i;
                resultsCount++;
            }
            i++;
        }

        contributorIndexes = new uint[](resultsCount);
        for (i = 0; i < resultsCount; i++) {
            contributorIndexes[i] = _contributorIndexes[i];
        }
        return contributorIndexes;
    }
}
