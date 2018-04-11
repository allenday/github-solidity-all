pragma solidity ^0.4.11;

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
*/

/// @title SITExchanger Contract
/// @author Anton Egorov
/// @dev This contract will be used to distribute MSP between SIT holders.
///  SIT token is not transferable, and we just keep an accounting between all tokens
///  deposited and the tokens collected.
///  The controllerShip of SIT should be transferred to this contract before the
///  contribution period starts.


import "./misc/SafeMath.sol";
import "./interface/Controlled.sol";
import "./interface/ERC20Token.sol";
import "./interface/MiniMeTokenI.sol";
import "./Contribution.sol";

contract SITExchanger is Controlled, TokenController {
  using SafeMath for uint256;

  mapping (address => uint256) public collected;
  uint256 public totalCollected;
  MiniMeTokenI public sit;
  MiniMeTokenI public msp;
  Contribution public contribution;

  function SITExchanger(address _sit, address _msp, address _contribution) {
    sit = MiniMeTokenI(_sit);
    msp = MiniMeTokenI(_msp);
    contribution = Contribution(_contribution);
  }

  /// @notice This method should be called by the SIT holders to collect their
  ///  corresponding MSPs
  function collect() public {
    // SIT sholder could collect MSP right after contribution started
    assert(getBlockNumber() > contribution.startBlock());

    // Get current MSP ballance
    uint256 balance = sit.balanceOfAt(msg.sender, contribution.initializedBlock());

    // And then subtract the amount already collected
    uint256 amount = balance.sub(collected[msg.sender]);

    require(amount > 0);  // Notify the user that there are no tokens to exchange

    totalCollected = totalCollected.add(amount);
    collected[msg.sender] = collected[msg.sender].add(amount);

    assert(msp.transfer(msg.sender, amount));

    TokensCollected(msg.sender, amount);
  }

  function proxyPayment(address) public payable returns (bool) {
    throw;
  }

  function onTransfer(address, address, uint256) public returns (bool) {
    return false;
  }

  function onApprove(address, address, uint256) public returns (bool) {
    return false;
  }

  //////////
  // Testing specific methods
  //////////

  /// @notice This function is overridden by the test Mocks.
  function getBlockNumber() internal constant returns (uint256) {
    return block.number;
  }

  //////////
  // Safety Method
  //////////

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  /// @param _token The address of the token contract that you want to recover
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) public onlyController {
    assert(_token != address(msp));
    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    ERC20Token token = ERC20Token(_token);
    uint256 balance = token.balanceOf(this);
    token.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }

  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event TokensCollected(address indexed _holder, uint256 _amount);

}
