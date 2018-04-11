pragma solidity ^0.4.8;

import 'zeppelin/ownership/Ownable.sol';
import 'zeppelin/token/ERC20.sol';

// This contract is a simple fund that is owned by another address.
// Any ERC20 tokens that are owned by this contract can be withdrawn to the owner.
contract SimpleFund is Ownable {
  
  // Allow the current owner to withdraw any tokens that are owned by this contract.
  function withdrawToken(ERC20 ownedToken, uint value) onlyOwner {
      if(!ownedToken.transfer(owner, value)){
          throw;
      }
  }
}