// create a contract to transfer referal bonuses pool
pragma solidity ^0.4.11;

import "./interface/Controlled.sol";
import "./interface/MiniMeTokenI.sol";

contract ReferalsTokenHolder is Controlled {
  MiniMeTokenI public msp;
  mapping (address => bool) been_spread;

  function ReferalsTokenHolder(address _msp) {
    msp = MiniMeTokenI(_msp);
  }

  function spread(address[] _addresses, uint256[] _amounts) public onlyController {
    require(_addresses.length == _amounts.length);

    for (uint256 i = 0; i < _addresses.length; i++) {
      address addr = _addresses[i];
      if (!been_spread[addr]) {
        uint256 amount = _amounts[i];
        assert(msp.transfer(addr, amount));
        been_spread[addr] = true;
      }
    }
  }

//////////
// Safety Methods
//////////

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  /// @param _token The address of the token contract that you want to recover
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) onlyController {
    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    ERC20Token token = ERC20Token(_token);
    uint balance = token.balanceOf(this);
    token.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }

  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}
