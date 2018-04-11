pragma solidity ^0.4.15;


contract Presale {
  //Transfers a portion of the beneficiary's funds to the presale, executing a purchase in the specified round
  function purchasePresale(address beneficiary, uint256 round) public payable;

  //Signals to the presale that no more committed funds remain
  function onPresaleComplete() public;
}
