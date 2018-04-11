pragma solidity ^0.4.11;

/*
  Copyright 2017, Jordi Baylina (Giveth)

  Original contract from https://github.com/aragon/aragon-network-token/blob/master/contracts/interface/ApproveAndCallReceiver.sol
*/

contract ApproveAndCallReceiver {
  function receiveApproval(address _from, uint256 _amount, address _token, bytes _data);
}
