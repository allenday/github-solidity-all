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

/// @title MSPPlaceholder Contract
/// @author Jordi Baylina
/// @dev The MSPPlaceholder contract will take control over the MSP after the contribution
///  is finalized and before the Mothership Network is deployed.
///  The contract allows for MSP transfers and transferFrom and implements the
///  logic for transferring control of the token to the network when the offering
///  asks it to do so.


import "./misc/SafeMath.sol";
import "./interface/Controlled.sol";
import "./interface/Refundable.sol";
import "./interface/TokenController.sol";
import "./interface/ERC20Token.sol";
import "./interface/MiniMeTokenI.sol";
import "./Contribution.sol";


contract MSPPlaceHolder is Controlled, TokenController, Refundable {
  using SafeMath for uint256;

  MiniMeTokenI public msp;
  Contribution public contribution;

  uint256 public activationTime;
  address public sitExchanger;

  /// @notice Constructor
  /// @param _controller Trusted controller for this contract.
  /// @param _msp MSP token contract address
  /// @param _contribution Contribution contract address
  /// @param _sitExchanger SIT-MSP Exchange address. (During the first day
  ///  only this exchanger will be able to move tokens)
  function MSPPlaceHolder(address _controller, address _msp, address _contribution, address _sitExchanger) {
    controller = _controller;
    msp = MiniMeTokenI(_msp);
    contribution = Contribution(_contribution);
    sitExchanger = _sitExchanger;
  }

  /// @notice The controller of this contract can change the controller of the MSP token
  ///  Please, be sure that the controller is a trusted agent or 0x0 address.
  /// @param _newController The address of the new controller

  function changeController(address _newController) public onlyController {
    msp.changeController(_newController);
    ControllerChanged(_newController);
  }

  function refund(address th, uint amount) returns (bool) {
    assert(msg.sender == address(contribution));
    msp.destroyTokens(th, amount);
    return true;
  }

  //////////
  // MiniMe Controller Interface functions
  //////////

  // In between the offering and the network. Default settings for allowing token transfers.
  function proxyPayment(address) public payable returns (bool) {
    return false;
  }

  function onTransfer(address _from, address, uint256) public returns (bool) {
    return transferable(_from);
  }

  function onApprove(address _from, address, uint256) public returns (bool) {
    return transferable(_from);
  }

  function transferable(address _from) internal returns (bool) {
    if (!contribution.goalMet()) return false;
    // Allow the exchanger to work from the beginning
    if (activationTime == 0) {
      uint256 f = contribution.finalizedTime();
      if (f > 0) {
        activationTime = f.add(24 hours);
      } else {
        return false;
      }
    }
    return (getTime() > activationTime) || (_from == sitExchanger);
  }


  //////////
  // Testing specific methods
  //////////

  /// @notice This function is overridden by the test Mocks.
  function getTime() internal returns (uint256) {
    return now;
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

  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event ControllerChanged(address indexed _newController);
}
