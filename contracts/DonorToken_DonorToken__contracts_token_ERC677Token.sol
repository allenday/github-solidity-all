pragma solidity ^0.4.13;

import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "./ERC23Token.sol";
import "../base/ERC677Contract.sol";


// implements ERC677
// see: https://github.com/ethereum/EIPs/issues/677
// help from https://github.com/ConsenSys/Tokens/blob/master/contracts/HumanStandardToken.sol
contract ERC677Token is StandardToken, ERC23Token {

  /* Approves and then calls the receiving contract */
  function approveAndCall(address _spender, uint256 _value, bytes _data) public returns (bool success) {
    super.approve(_spender, _value);

    // "it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead."
    require(ERC677Contract(_spender).receiveApproval(msg.sender, _value, this, _data));
    return true;
  }

  /* Transfers and then calls the receiving contract */
  function transferAndCall(address _to, uint256 _value, bytes _data) public returns (bool success) {
    super.transfer(_to, _value, _data);

    require(ERC677Contract(_to).receiveTransfer(msg.sender, _value, this, _data));
    return true;
  }

}
