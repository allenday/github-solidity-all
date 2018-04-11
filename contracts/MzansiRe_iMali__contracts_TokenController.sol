pragma solidity ^0.4.18;

/**
 * @title TokenController
 * @dev Functions to be used by a Token Controller
 */
contract TokenController {
  function proxyPayment(address _owner) payable public returns(bool);

  function onTransfer(address _from, address _to, uint _amount) public returns(bool);

  function onApprove(address _owner, address _spender, uint _amount) public returns(bool);
}