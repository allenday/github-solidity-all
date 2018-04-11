pragma solidity ^0.4.15;

import '../../contracts/KryptopyCrowdsale.sol';

// mock class using KryptopyCrowdsale
contract KryptopyCrowdsaleMock is KryptopyCrowdsale  {

  /*
  uint256 startBlock = block.number + 2; // blockchain block number where the crowdsale will commence. Here I just taking the current block that the contract and setting that the crowdsale starts two block after
  uint256 endBlock = startBlock + 300;   // blockchain block number where it will end. 300 is little over an hour.
  uint256 rate = 1000;                   // rate of ether to KrytopyToken in wei
  uint256 goal = 2500000000000000000000; // minimum amount of funds to be raised in wei
  uint256 cap = 12500000000000000000000; // max amount of funds raised in wei
  address wallet = msg.sender;           // the address that will hold the fund. Recommended to use a multisig one for security.

  function KryptopyCrowdsaleMock(address _tokenAddress)
    KryptopyCrowdsale(_tokenAddress, startBlock, endBlock, rate, goal, cap, wallet)
  { }
  */

  function KryptopyCrowdsaleMock (
    uint256 _startBlock,
    uint256 _endBlock,
    uint256 _rate,
    uint256 _goal,
    uint256 _cap,
    address _wallet
  )
    KryptopyCrowdsale(_startBlock, _endBlock, _rate, _goal, _cap, _wallet)
  {
  }

}
