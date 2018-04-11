pragma solidity ^0.4.15;

/*
 * Copyright 2017, Jordi Baylina (Giveth)
 * 
 * Changes made by IAM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: ApproveAndCallReceiver.sol
 * location: ERC23/contracts/token/interface/
 *
 */

contract ApproveAndCallReceiver {
    function receiveApproval(address _from, uint256 _amount, address _token, bytes _data);
}