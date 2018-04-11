pragma solidity ^0.4.18;

import "./MiniMeToken.sol";
import "./Controlled.sol";
import "./TokenController.sol";
import "./SafeMath.sol";
import "./RefundVault.sol";

contract Campaign is TokenController, Controlled {
    using SafeMath for uint256;

    uint256 public startFundingTime = 1512259200; // Dec 3, 2017 @ 00h00 UTC
    uint256 public endFundingTime = 1520035140; // Mar 2, 2018 @ 23h59 UTC
    
    uint256 public minimumGoal = 2000 ether;
    uint256 public maximumFunding = 10000 ether;  
    
    /*The entry threshold is set to 0.01 ETH which is equivalent to 10 Finney*/
    uint256 public purchaseThreshold = 10 finney;
    
    uint256 public totalCollected;      // counter for total ether collected
    MiniMeToken public tokenContract;   // The new token for this Campaign
       
    RefundVault public vault; // refund vault used to hold funds while crowdsale is running
    address public wallet; // wallet where ether will be sent on completion of successful campaign
    
    uint256 public constant campaignDuration = 90; // 1 Dec 2017 to 28 Feb 2018
    uint256 public constant degreesOfPrecision = 10**5; // precision used to compute floating values
    uint256 public constant maximumBonus = 25; // the maximum bonus for early purchasers equals 25%
    uint256 public constant iMaliPerEther = 500; // 1 ETH buys 500 IML excluding bonuses
    
    bool public isFinalized = false;
    event Finalized();
    
    address public bountyWallet;
    
    // helper function returns the current day of campaign when supplied with block.timestamp t
    function theDay(uint256 t) internal view returns (uint256) {
        for (uint256 i = 1; i <= campaignDuration; i++) {
            if(t < startFundingTime + i * 1 days) {
                return i;
            }
        }
    }
    
/*     
Bonus begins at 25% from 1 Dec 2017 and decreases to 0% on the 28 Feb 2018 in linear stepwise manner
*/
    // function that calculates the bonus for purchase of token at time t
    function theFloatMultiplier (uint256 t) public view returns (uint256, uint256, uint256) {
        
        // revert if time t is outside campaign duration
        if (t < startFundingTime || t > endFundingTime) {
            revert();
        }
        
        // determine the current day 
        uint256 thisDay = theDay(t);
        
        //                          (campaignDuration - thisDay)
        //            floatRatio = ------------------------------ x degreesOfPrecision  
        //                                campaignDuration
        // computes the linear decay value on thisDay, output ranges between [1,0] with 5 degrees of precision
        uint256 floatRatio = ((campaignDuration - thisDay)*degreesOfPrecision)/campaignDuration;
        
        //  (floatRatio x maximumBonus) computes the rational value for bonuses on thisDay                
        //  ceiling() returns the ceiling integer (to nearest unit) of computed value
        //  the bonus computation returns a multiplier of the form (1 + % thisDay's bonus)          
        uint256 bonus = theCeiling((floatRatio*maximumBonus), degreesOfPrecision) + 100*degreesOfPrecision;

        // computes the bonus inclusive number of tokens per ETH for thisDay        
        uint256 tokens = (bonus*iMaliPerEther) / (100*degreesOfPrecision);
        
        return (floatRatio, bonus, tokens);
    }
    
    // helper function computes the ceiling of input with respect to precision required
    function theCeiling(uint256 input, uint256 precision) internal pure returns (uint256 ) {
        return ((input + precision - 1) / precision) * precision;
    }
    
    
  
        function Campaign(address _walletAddress, address _tokenAddress, address _bountyWalletAdress) {
        
        require ((_endFundingTime >= now) &&           // Cannot end in the past
            (_endFundingTime > _startFundingTime) &&
            (_walletAddress != address(0x0)) &&
            (_bountyWalletAdressAddress != address(0x0)));     
            
        tokenContract = MiniMeToken(_tokenAddress);    // The Deployed Token Contract
        wallet = _walletAddress;
        vault = new RefundVault(wallet);
        bountyWallet = _bountyWalletAdress;
    }

/// @dev The fallback function is called when ether is sent to the contract, it
/// simply calls `doPayment()` with the address that sent the ether as the
/// `_owner`. Payable is a required solidity modifier for functions to receive
/// ether, without this modifier functions will throw if ether is sent to them

    function ()  payable {
        doPayment(msg.sender);
    }

/////////////////
// TokenController interface
/////////////////

/// @notice `proxyPayment()` allows the caller to send ether to the Campaign and
/// have the tokens created in an address of their choosing
/// @param _owner The address that will hold the newly created tokens

    function proxyPayment(address _owner) payable returns(bool) {
        doPayment(_owner);
        return true;
    }

/// @notice Notifies the controller about a transfer, for this Campaign all
///  transfers are allowed by default and no extra notifications are needed
/// @param _from The origin of the transfer
/// @param _to The destination of the transfer
/// @param _amount The amount of the transfer
/// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) returns(bool) {
        return true;
    }

/// @notice Notifies the controller about an approval, for this Campaign all
///  approvals are allowed by default and no extra notifications are needed
/// @param _owner The address that calls `approve()`
/// @param _spender The spender in the `approve()` call
/// @param _amount The amount in the `approve()` call
/// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool)
    {
        return true;
    }


/// @dev `doPayment()` is an internal function that sends the ether that this
///  contract receives to the `vault` and creates tokens in the address of the
///  `_owner` assuming the Campaign is still accepting funds
/// @param _owner The address that will hold the newly created tokens

    function doPayment(address _owner) internal {
        
        uint256 timeNow = block.timestamp;
        
// First check that the Campaign is allowed to receive this donation
        require ((timeNow >= startFundingTime) &&
            (timeNow <= endFundingTime) &&
            (tokenContract.controller() != address(0x0)) &&           // Extra check
            (msg.value > purchaseThreshold) &&
            (totalCollected.add(msg.value) <= maximumFunding));

//Track how much the Campaign has collected
        totalCollected = totalCollected.add(msg.value);

//Send the ether to the vault
        forwardFunds();
        //require (vault.send(msg.value));

        
        var (linearDecay, bonusMultiplier, tokensPerEther)  = theFloatMultiplier(timeNow);
        
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(tokensPerEther);


// Creates the amount of tokens . The new tokens are created
//  in the `_owner` address
        require (tokenContract.generateTokens(_owner, tokens));

        return;
    }

function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  function finalize() onlyController public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }
  
  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
      vault.close();
      createBountyTokens();
      createReserveTokens();
    } else {
      vault.enableRefunds();
    }
    
    tokenContract.transferControl(0x0);

  }
 
  function createBountyTokens() internal {
    uint256 bountyAllocation = 1250000*10**18;
    require (tokenContract.generateTokens(bountyWallet, bountyAllocation));
  }

  function createReserveTokens() internal {
    uint256 reserveAllocation = 2500000*10**18;
    require (tokenContract.generateTokens(wallet, reserveAllocation));
  }
  
  function goalReached() public constant returns (bool) {
    return totalCollected >= minimumGoal;
  }

  function hasEnded() public constant returns (bool) {
    return now > endFundingTime;
  }
  
}