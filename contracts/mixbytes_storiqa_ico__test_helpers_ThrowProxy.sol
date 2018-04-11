pragma solidity ^0.4.0;


// Proxy contract for testing throws
contract ThrowProxy {
  address public target;
  bool public thrown;

  function ThrowProxy(address _target) {
    target = _target;
  }

  //prime the data using the fallback function.
  function() {
    thrown = !(target.call.gas(200000)(msg.data));
  }
}
