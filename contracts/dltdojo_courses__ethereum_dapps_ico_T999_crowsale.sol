pragma solidity ^0.4.14;
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/examples/SampleCrowdsale.sol
// https://github.com/dltdojo/courses/blob/master/ethereum/solidity/T240_CrowdSale.sol
contract SampleCrowdsale{
  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

   // low level token purchase function
  function buyTokens(address beneficiary) payable {
    require(beneficiary != 0x0);
  }
}