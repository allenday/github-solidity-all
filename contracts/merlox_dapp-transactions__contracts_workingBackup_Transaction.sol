pragma solidity ^0.4.11;

contract Transaction {

    address owner = msg.sender;

   bytes32 sellerName;
   address sellerAddress;
   bytes32 sellerEmail;
   bytes32 sellerGpsLocation;
   bytes32 sellerCashLedgerAddress;
   bytes32 sellerAssetsLedgerAddress;
   uint sellerVatNumber;

   address buyerAddress;
   bytes32 buyerName;
   bytes32 buyerEmail;
   bytes32 buyerGpsLocation;
   bytes buyerCashLedgerAddress;
   bytes buyerAssetsLedgerAddress;
   uint buyerVatNumber;

   bytes invoiceHashAddress;

   uint timestamp;
   uint quantityBought;
   uint amountPaidWei;
   uint pricePerItem;
   uint vat; // Not set on the constructor

   modifier onlyOwner(){
        if(msg.sender == owner)
        _;
    }

    function() payable {}

    function extractEther() onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function Transaction(
        address[2] buyerSellerAddress, bytes _invoiceHashAddress, uint price,
        bytes32[2] sellerNameEmail, uint[3] buyerVatQuantityPriceItem,
        bytes32[3] buyerNameEmailGpsLocation, bytes buyerCashLedger, bytes buyerAssetsLedger
    ){
        timestamp = block.timestamp;
        amountPaidWei = price;
        buyerAddress = buyerSellerAddress[0];
        sellerAddress = buyerSellerAddress[1];
        invoiceHashAddress = _invoiceHashAddress;
        sellerName = sellerNameEmail[0];
        sellerEmail = sellerNameEmail[1];
        buyerVatNumber = buyerVatQuantityPriceItem[0];
        quantityBought = buyerVatQuantityPriceItem[1];
        pricePerItem = buyerVatQuantityPriceItem[2];
        buyerName = buyerNameEmailGpsLocation[0];
        buyerEmail = buyerNameEmailGpsLocation[1];
        buyerGpsLocation = buyerNameEmailGpsLocation[2];
        buyerCashLedgerAddress = buyerCashLedger;
        buyerAssetsLedgerAddress = buyerAssetsLedger;
    }

    function getInitialData() constant returns(
        bytes32, address, bytes32, address, bytes32, bytes32, bytes32, uint, uint, uint, uint){
        return(
            buyerName, sellerAddress, buyerEmail, buyerAddress, buyerGpsLocation,
            sellerName, sellerEmail, buyerVatNumber, quantityBought, pricePerItem, amountPaidWei
        );
    }

    function getHashAddresses() constant returns(bytes, bytes, bytes){
        return(
            invoiceHashAddress, buyerCashLedgerAddress, buyerAssetsLedgerAddress
        );
    }

   function releaseFundsWhenBothSigned(){

   }

   function storeLedgersInIpfs(){
      // Generate and update both ledgers with details of the transaction
      // then save them in IPFS using IPFS-API maintaining the hash of them
   }

   function kill(){
       selfdestruct(owner);
   }
}
