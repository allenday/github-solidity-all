pragma solidity 0.4.11;

import "../ERC20.sol";
import "../ownership/Ownable.sol";
import "../controller/ControllerInterface.sol";
import "../ERC223ReceivingContract.sol";
import "../PullPayInterface.sol";


/**
 * Nutz implements a price floor and a price ceiling on the token being
 * sold. It is based of the zeppelin token contract.
 */
contract Nutz is Ownable, ERC20 {

  event Sell(address indexed seller, uint256 value);

  string public name = "Acebusters Nutz";
  // acebusters units:
  // 10^12 - Nutz   (NTZ)
  // 10^9 - Jonyz
  // 10^6 - Helcz
  // 10^3 - Pascalz
  // 10^0 - Babz
  string public symbol = "NTZ";
  uint256 public decimals = 12;

  // returns balances of active holders
  function balanceOf(address _owner) constant returns (uint) {
    return ControllerInterface(owner).babzBalanceOf(_owner);
  }

  function totalSupply() constant returns (uint256) {
    return ControllerInterface(owner).totalSupply();
  }

  function activeSupply() constant returns (uint256) {
    return ControllerInterface(owner).activeSupply();
  }

  // return remaining allowance
  // if calling return allowed[address(this)][_spender];
  // returns balance of ether parked to be withdrawn
  function allowance(address _owner, address _spender) constant returns (uint256) {
    return ControllerInterface(owner).allowance(_owner, _spender);
  }

  // returns either the salePrice, or if reserve does not suffice
  // for active supply, returns maxFloor
  function floor() constant returns (uint256) {
    return ControllerInterface(owner).floor();
  }

  // returns either the salePrice, or if reserve does not suffice
  // for active supply, returns maxFloor
  function ceiling() constant returns (uint256) {
    return ControllerInterface(owner).ceiling();
  }

  function powerPool() constant returns (uint256) {
    return ControllerInterface(owner).powerPool();
  }


  function _checkDestination(address _from, address _to, uint256 _value, bytes _data) internal {
    // erc223: Retrieve the size of the code on target address, this needs assembly .
    uint256 codeLength;
    assembly {
      codeLength := extcodesize(_to)
    }
    if(codeLength>0) {
      ERC223ReceivingContract untrustedReceiver = ERC223ReceivingContract(_to);
      // untrusted contract call
      untrustedReceiver.tokenFallback(_from, _value, _data);
    }
  }



  // ############################################
  // ########### ADMIN FUNCTIONS ################
  // ############################################

  function powerDown(address powerAddr, address _holder, uint256 _amountBabz) public onlyOwner {
    bytes memory empty;
    _checkDestination(powerAddr, _holder, _amountBabz, empty);
    // NTZ transfered from power pool to user's balance
    Transfer(powerAddr, _holder, _amountBabz);
  }


  function asyncSend(address _pullAddr, address _dest, uint256 _amountWei) public onlyOwner {
    assert(_amountWei <= this.balance);
    PullPayInterface(_pullAddr).asyncSend.value(_amountWei)(_dest);
  }


  // ############################################
  // ########### PUBLIC FUNCTIONS ###############
  // ############################################

  function approve(address _spender, uint256 _amountBabz) public {
    ControllerInterface(owner).approve(msg.sender, _spender, _amountBabz);
    Approval(msg.sender, _spender, _amountBabz);
  }

  function transfer(address _to, uint256 _amountBabz, bytes _data) public returns (bool) {
    ControllerInterface(owner).transfer(msg.sender, _to, _amountBabz, _data);
    Transfer(msg.sender, _to, _amountBabz);
    _checkDestination(msg.sender, _to, _amountBabz, _data);
    return true;
  }

  function transfer(address _to, uint256 _amountBabz) public returns (bool) {
    bytes memory empty;
    return transfer(_to, _amountBabz, empty);
  }

  function transData(address _to, uint256 _amountBabz, bytes _data) public returns (bool) {
    return transfer(_to, _amountBabz, _data);
  }

  function transferFrom(address _from, address _to, uint256 _amountBabz, bytes _data) public returns (bool) {
    ControllerInterface(owner).transferFrom(msg.sender, _from, _to, _amountBabz, _data);
    Transfer(_from, _to, _amountBabz);
    _checkDestination(_from, _to, _amountBabz, _data);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _amountBabz) public returns (bool) {
    bytes memory empty;
    return transferFrom(_from, _to, _amountBabz, empty);
  }

  function () public payable {
    uint256 price = ControllerInterface(owner).ceiling();
    purchase(price);
    require(msg.value > 0);
  }

  function purchase(uint256 _price) public payable {
    require(msg.value > 0);
    uint256 amountBabz = ControllerInterface(owner).purchase(msg.sender, msg.value, _price);
    Transfer(owner, msg.sender, amountBabz);
    bytes memory empty;
    _checkDestination(address(this), msg.sender, amountBabz, empty);
  }

  function sell(uint256 _price, uint256 _amountBabz) public {
    require(_amountBabz != 0);
    ControllerInterface(owner).sell(msg.sender, _price, _amountBabz);
    Sell(msg.sender, _amountBabz);
  }

  function powerUp(uint256 _amountBabz) public {
    Transfer(msg.sender, owner, _amountBabz);
    ControllerInterface(owner).powerUp(msg.sender, msg.sender, _amountBabz);
  }

}
