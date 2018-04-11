pragma solidity ^0.4.6;

contract Quotation {
    uint public greenness;
    string public deliveryDate;

    function Quotation(uint greenness_, string deliveryDate_) {
        greenness = greenness_;
        deliveryDate = deliveryDate_;
    }
}
