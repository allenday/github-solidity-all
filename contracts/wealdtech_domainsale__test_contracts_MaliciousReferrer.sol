pragma solidity ^0.4.11;


// A referrer that acts like a normal DomainSale referer but throws
// rather than accepting payment
contract MaliciousReferrer {

    // Refuse to receive funds
    function () payable {
        revert();
    }
}
