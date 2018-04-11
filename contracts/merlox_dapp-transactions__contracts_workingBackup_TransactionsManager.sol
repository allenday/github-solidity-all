pragma solidity ^0.4.11;

import "./Transaction.sol";

/* The manager will generate instances of the Transactions like a database */
contract TransactionsManager{
   address[] pendingTransactionInstances;
   address[] pendingTransactionInstancesSellerAddress;
   address[] completedTransactionInstances;
   address[] cancelledTransactionInstances;
   bytes[] invoiceHashAddresses;
   address owner = msg.sender;

   mapping(address => address) sellerAddressInstance;

    modifier onlyOwner(){
        if(msg.sender == owner)
        _;
    }

    function() payable {}

    function extractEther() onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function generateInstance(address[2] buyerSellerAddress, bytes invoiceHashAddress,
    bytes32[2] sellerNameEmail, uint[3] buyerVatQuantityPriceItem,
    bytes32[3] buyerNameEmailGpsLocation, bytes buyerCashLedger, bytes buyerAssetsLedger) payable{

        Transaction t = new Transaction(
            buyerSellerAddress, invoiceHashAddress, msg.value, sellerNameEmail, buyerVatQuantityPriceItem,
            buyerNameEmailGpsLocation, buyerCashLedger, buyerAssetsLedger
        );

        pendingTransactionInstances.push(t);
        invoiceHashAddresses.push(invoiceHashAddress);
        pendingTransactionInstancesSellerAddress.push(buyerSellerAddress[1]);
        sellerAddressInstance[buyerSellerAddress[1]] = t;
    }

   function getPendingTransactions() constant returns(address[]){
       return pendingTransactionInstances;
   }

   // Get the seller addresses, check if the current user's address is in there
    function getPendingTransactionsSellerAddresses() constant returns(address[]){
       return pendingTransactionInstancesSellerAddress;
   }

   // Given the seller address, get his instance smart contract address
   function getInstanceAddress(address sellerAddress) constant returns(address){
       return sellerAddressInstance[sellerAddress];
   }

   function getCompletedTransactions() constant returns(address[]){
       return completedTransactionInstances;
   }

    function getInvoiceHashAddresses() constant returns(bytes){
       return invoiceHashAddresses[0];
   }

   function killInstance(address instanceAddress, address instanceSellerAddress){
       Transaction t = Transaction(instanceAddress);

       sellerAddressInstance[instanceSellerAddress] = 0;

       for(uint i = 0; i < pendingTransactionInstances.length; i++){
           if(pendingTransactionInstances[i] == instanceAddress){
               pendingTransactionInstances[i] = address(0);
               break;
           }
       }

       for(uint a = 0; a < pendingTransactionInstancesSellerAddress.length; a++){
           if(pendingTransactionInstancesSellerAddress[a] == instanceSellerAddress){
               pendingTransactionInstancesSellerAddress[a] = address(0);
               break;
           }
       }

       cancelledTransactionInstances.push(instanceAddress);
       t.kill();
   }

   function kill() onlyOwner{
       selfdestruct(owner);
   }
}
