pragma solidity 0.4.19;

contract Y {
    address payee;
    Proportion public donationProportion;
    struct Proportion {
        uint num; // numerator
        uint denom; // denominator
    }

    function Y(uint num, uint denom) public {
        require(0 < num && num < denom); // 0 < num/denom < 1
        donationProportion = Proportion(num, denom);
        payee = msg.sender;
    }

    // function payAndDonate(address payee, address donee) public payable {
        // uint donation = (msg.value * 25) / 100;
        // payee.transfer(msg.value - donation);
        // donee.transfer(donation);
    // }

    function setDonationProportion(uint num, uint denom) public returns (bool success) {
        require(0 < num && num < denom); // 0 < num/denom < 1
        require(msg.sender == payee);
        donationProportion = Proportion(num, denom);
        return true;
    }
}
