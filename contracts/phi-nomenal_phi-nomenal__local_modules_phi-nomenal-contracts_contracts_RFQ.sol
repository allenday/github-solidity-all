pragma solidity ^0.4.6;

contract RFQ { // Request for Quotation
    string public product;
    uint public amount;
    string public deliveryRegion;

    function RFQ(string product_, uint amount_, string deliveryRegion_) {
        product = product_;
        amount = amount_;
        deliveryRegion = deliveryRegion_;
    }
}
