pragma solidity ^0.4.15;

import "./Transaction.sol";

/// @title Transaction Manager: Creates instances of Transactions and manages
/// those active instances for triple entry accounting
/// @author Merunas Grincalaitis
contract TransactionsManager{

   // The address of the instance given the seller's address
   // sellerAddress => instanceAddress
   mapping(address => address) sellerAddressInstance;

   // Completed seller transactions
   // sellerAddress => instanceAddress
   mapping(address => address) sellerEndedTransactions;

   // The address of the instance given the buyer's address
   // buyerAddress => instanceAddress
   mapping(address => address) buyerAddressInstance;

   // Checks that the seller address has an instance
   modifier existingSellerInstance(address sellerAddress) {
       require(sellerAddressInstance[sellerAddress] != 0x0);
       _;
   }

   /// @notice Generates an invoice instance for the buyer `msg.sender` and
   /// saves the instance address in the pending transactions Array
   /// @param buyerName the buyer's name
   /// @param buyerEmail the buyer's email
   /// @param buyerWalletAddress the wallet address of the buyer
   /// @param buyerCompleteAddress the complete address of the buyer including
   /// @param sellerName the name of the seller
   /// @param sellerEmail the email of the seller
   /// @param sellerWalletAddress the address of the seller's wallet
   /// @param sellerCompleteAddress the complete address of the seller just like
   /// @param itemName the name of the item
   /// @param itemPrice the price in Wei of the item
   /// @param itemQuantity the quantity that you want to buy
   /// @param invoiceHashAddress the IPFS hash address of the generated invoice
   function createInstance(
      bytes32 buyerName,
      bytes32 buyerEmail,
      address buyerWalletAddress,
      bytes buyerCompleteAddress,
      bytes32 sellerName,
      bytes32 sellerEmail,
      address sellerWalletAddress,
      bytes sellerCompleteAddress,
      bytes32 itemName,
      uint itemPrice,
      uint itemQuantity,
      bytes invoiceHashAddress
   ) payable {

         // Send the ether paid for the transaction when creating the contract
        Transaction t = (new Transaction).value(msg.value)(
            buyerName,
            buyerEmail,
            buyerWalletAddress,
            buyerCompleteAddress,
            sellerName,
            sellerEmail,
            sellerWalletAddress,
            sellerCompleteAddress,
            itemName,
            itemPrice,
            itemQuantity,
            invoiceHashAddress
        );

        sellerAddressInstance[sellerWalletAddress] = t;
        buyerAddressInstance[buyerWalletAddress] = t;
    }


    /// @notice Releases the funds of the specified contract and ends the instance
    function releaseFunds(bool forSeller) existingSellerInstance(msg.sender) {
      Transaction instance = Transaction(sellerAddressInstance[msg.sender]);

      require(msg.sender == instance.sellerWalletAddress() || msg.sender == instance.buyerWalletAddress());

      if(forSeller)
        instance.releaseFundsSeller();
      else
        instance.releaseFundsBuyer();
    }

    /// @notice Kills an instance by updating this contract's state arrays and
    /// executing the kill function of the instance. Also stores the instance address
    /// in the cancelled transactions array
    /// @param sellerAddress the seller address of the instance to kill
    /// @param buyerAddress the address of the buyer to update the waiting counter-sign
    /// state array
    function endInstance(
       address sellerAddress,
       address buyerAddress
    ) existingSellerInstance(msg.sender) {
       Transaction instance = Transaction(sellerAddressInstance[sellerAddress]);

       require(msg.sender == instance.sellerWalletAddress() || msg.sender == instance.buyerWalletAddress());

       sellerAddressInstance[sellerAddress] = 0x0;
       buyerAddressInstance[buyerAddress] = 0x0;
       sellerEndedTransactions[sellerAddress] = instance;
    }

   /// @notice Returns the instance address given a seller address
   /// @param sellerAddress the address of the seller
   function getInstanceAddress(address sellerAddress) constant returns(address){
       return sellerAddressInstance[sellerAddress];
   }

   /// @notice Returns the instance address given a buyer address
   /// @param buyerAddress the address of the buyer
   function getBuyerInstanceAddress(address buyerAddress) constant returns(address){
       return buyerAddressInstance[buyerAddress];
   }
}
