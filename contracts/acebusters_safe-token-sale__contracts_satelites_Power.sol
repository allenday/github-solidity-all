pragma solidity 0.4.11;

import "../ERC20Basic.sol";
import "../ownership/Ownable.sol";
import "../controller/ControllerInterface.sol";

contract Power is Ownable, ERC20Basic {

  event Slashing(address indexed holder, uint value, bytes32 data);

  string public name = "Acebusters Power";
  string public symbol = "ABP";
  uint256 public decimals = 12;


  function balanceOf(address _holder) constant returns (uint256) {
    return ControllerInterface(owner).powerBalanceOf(_holder);
  }

  function totalSupply() constant returns (uint256) {
    return ControllerInterface(owner).powerTotalSupply();
  }

  function activeSupply() constant returns (uint256) {
    return ControllerInterface(owner).outstandingPower();
  }


  // ############################################
  // ########### ADMIN FUNCTIONS ################
  // ############################################

  function slashPower(address _holder, uint256 _value, bytes32 _data) public onlyOwner {
    Slashing(_holder, _value, _data);
  }

  function powerUp(address _holder, uint256 _value) public onlyOwner {
    // NTZ transfered from user's balance to power pool
    Transfer(address(0), _holder, _value);
  }

  // ############################################
  // ########### PUBLIC FUNCTIONS ###############
  // ############################################

  // registers a powerdown request
  function transfer(address _to, uint256 _amountPower) public returns (bool success) {
    // make Power not transferable
    require(_to == address(0));
    ControllerInterface(owner).createDownRequest(msg.sender, _amountPower);
    Transfer(msg.sender, address(0), _amountPower);
    return true;
  }

  function downtime() public returns (uint256) {
    ControllerInterface(owner).downtime;
  }

  function downTick(address _owner) public {
    ControllerInterface(owner).downTick(_owner, now);
  }

  function downs(address _owner) constant public returns (uint256, uint256, uint256) {
    return ControllerInterface(owner).downs(_owner);
  }

}
