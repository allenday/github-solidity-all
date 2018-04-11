pragma solidity ^0.4.11;

import "./misc/SafeMath.sol";
import "./interface/Controlled.sol";
import "./interface/Refundable.sol";
import "./interface/TokenController.sol";
import "./interface/MiniMeTokenI.sol";
import "./interface/Finalizable.sol";

/*
  Copyright 2017, Anton Egorov (Mothership Foundation)
  Copyright 2017, Jordi Baylina (Giveth)

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

  Based on SampleCampaign-TokenController.sol from https://github.com/Giveth/minime
  Original contract is https://github.com/status-im/status-network-token/blob/master/contracts/StatusContribution.sol
*/

contract Contribution is Controlled, TokenController, Finalizable {
  using SafeMath for uint256;

  uint256 public totalSupplyCap; // Total MSP supply to be generated
  uint256 public exchangeRate; // ETH-MSP exchange rate
  uint256 public totalSold; // How much tokens sold
  uint256 public totalSaleSupplyCap; // Token sale cap

  MiniMeTokenI public sit;
  MiniMeTokenI public msp;

  uint256 public startBlock;
  uint256 public endBlock;

  address public destEthDevs;
  address public destTokensSit;
  address public destTokensTeam;
  address public destTokensReferals;

  address public mspController;

  uint256 public initializedBlock;
  uint256 public finalizedTime;

  uint256 public minimum_investment;
  uint256 public minimum_goal;

  bool public paused;

  modifier initialized() {
    assert(address(msp) != 0x0);
    _;
  }

  modifier contributionOpen() {
    assert(getBlockNumber() >= startBlock &&
            getBlockNumber() <= endBlock &&
            finalizedBlock == 0 &&
            address(msp) != 0x0);
    _;
  }

  modifier notPaused() {
    require(!paused);
    _;
  }

  function Contribution() {
    // Booleans are false by default consider removing this
    paused = false;
  }

  /// @notice This method should be called by the controller before the contribution
  ///  period starts This initializes most of the parameters
  /// @param _msp Address of the MSP token contract
  /// @param _mspController Token controller for the MSP that will be transferred after
  ///  the contribution finalizes.
  /// @param _totalSupplyCap Maximum amount of tokens to generate during the contribution
  /// @param _exchangeRate ETH to MSP rate for the token sale
  /// @param _startBlock Block when the contribution period starts
  /// @param _endBlock The last block that the contribution period is active
  /// @param _destEthDevs Destination address where the contribution ether is sent
  /// @param _destTokensSit Address of the exchanger SIT-MSP where the MSP are sent
  ///  to be distributed to the SIT holders.
  /// @param _destTokensTeam Address where the tokens for the team are sent
  /// @param _destTokensReferals Address where the tokens for the referal system are sent
  /// @param _sit Address of the SIT token contract
  function initialize(
      address _msp,
      address _mspController,

      uint256 _totalSupplyCap,
      uint256 _exchangeRate,
      uint256 _minimum_goal,

      uint256 _startBlock,
      uint256 _endBlock,

      address _destEthDevs,
      address _destTokensSit,
      address _destTokensTeam,
      address _destTokensReferals,

      address _sit
  ) public onlyController {
    // Initialize only once
    assert(address(msp) == 0x0);

    msp = MiniMeTokenI(_msp);
    assert(msp.totalSupply() == 0);
    assert(msp.controller() == address(this));
    assert(msp.decimals() == 18);  // Same amount of decimals as ETH

    require(_mspController != 0x0);
    mspController = _mspController;

    require(_exchangeRate > 0);
    exchangeRate = _exchangeRate;

    assert(_startBlock >= getBlockNumber());
    require(_startBlock < _endBlock);
    startBlock = _startBlock;
    endBlock = _endBlock;

    require(_destEthDevs != 0x0);
    destEthDevs = _destEthDevs;

    require(_destTokensSit != 0x0);
    destTokensSit = _destTokensSit;

    require(_destTokensTeam != 0x0);
    destTokensTeam = _destTokensTeam;

    require(_destTokensReferals != 0x0);
    destTokensReferals = _destTokensReferals;

    require(_sit != 0x0);
    sit = MiniMeTokenI(_sit);

    initializedBlock = getBlockNumber();
    // SIT amount should be no more than 20% of MSP total supply cap
    assert(sit.totalSupplyAt(initializedBlock) * 5 <= _totalSupplyCap);
    totalSupplyCap = _totalSupplyCap;

    // We are going to sale 70% of total supply cap
    totalSaleSupplyCap = percent(70).mul(_totalSupplyCap).div(percent(100));

    minimum_goal = _minimum_goal;
  }

  function setMinimumInvestment(
      uint _minimum_investment
  ) public onlyController {
    minimum_investment = _minimum_investment;
  }

  function setExchangeRate(
      uint _exchangeRate
  ) public onlyController {
    assert(getBlockNumber() < startBlock);
    exchangeRate = _exchangeRate;
  }

  /// @notice If anybody sends Ether directly to this contract, consider he is
  ///  getting MSPs.
  function () public payable notPaused {
    proxyPayment(msg.sender);
  }


  //////////
  // TokenController functions
  //////////

  /// @notice This method will generally be called by the MSP token contract to
  ///  acquire MSPs. Or directly from third parties that want to acquire MSPs in
  ///  behalf of a token holder.
  /// @param _th MSP holder where the MSPs will be minted.
  function proxyPayment(address _th) public payable notPaused initialized contributionOpen returns (bool) {
    require(_th != 0x0);
    doBuy(_th);
    return true;
  }

  function onTransfer(address, address, uint256) public returns (bool) {
    return false;
  }

  function onApprove(address, address, uint256) public returns (bool) {
    return false;
  }

  function doBuy(address _th) internal {
    require(msg.value >= minimum_investment);

    // Antispam mechanism
    address caller;
    if (msg.sender == address(msp)) {
      caller = _th;
    } else {
      caller = msg.sender;
    }

    // Do not allow contracts to game the system
    assert(!isContract(caller));

    uint256 toFund = msg.value;
    uint256 leftForSale = tokensForSale();
    if (toFund > 0) {
      if (leftForSale > 0) {
        uint256 tokensGenerated = toFund.mul(exchangeRate);

        // Check total supply cap reached, sell the all remaining tokens
        if (tokensGenerated > leftForSale) {
          tokensGenerated = leftForSale;
          toFund = leftForSale.div(exchangeRate);
        }

        assert(msp.generateTokens(_th, tokensGenerated));
        totalSold = totalSold.add(tokensGenerated);
        if (totalSold >= minimum_goal) {
          goalMet = true;
        }
        destEthDevs.transfer(toFund);
        NewSale(_th, toFund, tokensGenerated);
      } else {
        toFund = 0;
      }
    }

    uint256 toReturn = msg.value.sub(toFund);
    if (toReturn > 0) {
      // If the call comes from the Token controller,
      // then we return it to the token Holder.
      // Otherwise we return to the sender.
      if (msg.sender == address(msp)) {
        _th.transfer(toReturn);
      } else {
        msg.sender.transfer(toReturn);
      }
    }
  }

  /// @dev Internal function to determine if an address is a contract
  /// @param _addr The address being queried
  /// @return True if `_addr` is a contract
  function isContract(address _addr) constant internal returns (bool) {
    if (_addr == 0) return false;
    uint256 size;
    assembly {
      size := extcodesize(_addr)
    }
    return (size > 0);
  }

  function refund() public {
    require(finalizedBlock != 0);
    require(!goalMet);

    uint256 amountTokens = msp.balanceOf(msg.sender);
    require(amountTokens > 0);
    uint256 amountEther = amountTokens.div(exchangeRate);
    address th = msg.sender;

    Refundable(mspController).refund(th, amountTokens);
    Refundable(destEthDevs).refund(th, amountEther);

    Refund(th, amountTokens, amountEther);
  }

  event Refund(address _token_holder, uint256 _amount_tokens, uint256 _amount_ether);

  /// @notice This method will can be called by the controller before the contribution period
  ///  end or by anybody after the `endBlock`. This method finalizes the contribution period
  ///  by creating the remaining tokens and transferring the controller to the configured
  ///  controller.
  function finalize() public initialized {
    assert(getBlockNumber() >= startBlock);
    assert(msg.sender == controller || getBlockNumber() > endBlock || tokensForSale() == 0);
    require(finalizedBlock == 0);

    finalizedBlock = getBlockNumber();
    finalizedTime = now;

    if (goalMet) {
      // Generate 5% for the team
      assert(msp.generateTokens(
        destTokensTeam,
        percent(5).mul(totalSupplyCap).div(percent(100))));

      // Generate 5% for the referal bonuses
      assert(msp.generateTokens(
        destTokensReferals,
        percent(5).mul(totalSupplyCap).div(percent(100))));

      // Generate tokens for SIT exchanger
      assert(msp.generateTokens(
        destTokensSit,
        sit.totalSupplyAt(initializedBlock)));
    }

    msp.changeController(mspController);
    Finalized();
  }

  function percent(uint256 p) internal returns (uint256) {
    return p.mul(10**16);
  }


  //////////
  // Constant functions
  //////////

  /// @return Total tokens issued in weis.
  function tokensIssued() public constant returns (uint256) {
    return msp.totalSupply();
  }

  /// @return Total tokens availale for the sale in weis.
  function tokensForSale() public constant returns(uint256) {
    return totalSaleSupplyCap > totalSold ? totalSaleSupplyCap - totalSold : 0;
  }


  //////////
  // Testing specific methods
  //////////

  /// @notice This function is overridden by the test Mocks.
  function getBlockNumber() internal constant returns (uint256) {
    return block.number;
  }


  //////////
  // Safety Methods
  //////////

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  /// @param _token The address of the token contract that you want to recover
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) public onlyController {
    if (msp.controller() == address(this)) {
      msp.claimTokens(_token);
    }
    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    ERC20Token token = ERC20Token(_token);
    uint256 balance = token.balanceOf(this);
    token.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }


  /// @notice Pauses the contribution if there is any issue
  function pauseContribution() onlyController {
    paused = true;
  }

  /// @notice Resumes the contribution
  function resumeContribution() onlyController {
    paused = false;
  }

  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event NewSale(address indexed _th, uint256 _amount, uint256 _tokens);
  event Finalized();
}
