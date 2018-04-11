pragma solidity ^0.4.8;

import 'zeppelin/ownership/Ownable.sol';
import 'zeppelin/token/ERC20.sol';

// This contract is a simple fund that is owned by another address.
// Any ERC20 tokens that are owned by this contract can be withdrawn to the owner.
// The original owner can sell it to another owner by accepting a specified amount of ETH.
// The current owner can set the price to 0 to mark it as "not for sale" or any price above 0 to allow someone to buy.
contract SellableFund is Ownable {

  // Price required to purchase fund - 0 means "not for sale"
  uint public salePrice;
  
  // Constructor sets the price someone will need to pa to take ownership
  function SellableFund(uint originalSalePrice){      
      salePrice = originalSalePrice;
  }


  // Allow the current owner to withdraw any tokens that are owned by this contract.
  function withdrawToken(ERC20 ownedToken, uint value) onlyOwner {
      if(!ownedToken.transfer(owner, value)){
          throw;
      }
  }

  // Allow anyone to purchase this fund if they pay the price and make them update the price.
  function purchase() payable {
      
      // If the salePrice is set to 0, block anyone from purchasing it as it is not for sale.
      if(salePrice == 0){
          throw;
      }

      // If the amount of ETH sent in is not enough to cover the cost, reject it
      if(msg.value < salePrice){
          throw;
      } 

      // Update the sale price to 0 so that it is not for sale until the current owner updates it
      salePrice = 0;

      // Grab the old owner address to know where to send the payment
      address previousOwner = owner;

      // Update the owner of the fund to the purchaser
      owner = msg.sender;      

      // Send ETH to previousOwner to finalize the purchase
      if(!previousOwner.send(msg.value)){
          throw;
      }
  }

  // Allow the current owner to update the sale price - set to 0 to prevent purchases
  function updatePrice(uint newSalePrice) onlyOwner {
    salePrice = newSalePrice;
  }
}