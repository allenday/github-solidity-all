pragma solidity 0.4.11;


import '../../contracts/ERC223ReceivingContract.sol';
import '../../contracts/satelites/Nutz.sol';


// mock class using StandardToken
contract ERC223ReceiverMock is ERC223ReceivingContract {

  bool public called = false;

  function tokenFallback(address _from, uint _value, bytes _data) {
    called = true;
  }

  function () payable {
  }

  function forward(address _to, uint256 _value, uint256 _price) {
  	Nutz(_to).purchase.value(_value)(_price);
  }

}
