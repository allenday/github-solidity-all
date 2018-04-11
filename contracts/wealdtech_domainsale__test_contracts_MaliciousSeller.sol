pragma solidity ^0.4.11;


import '../../contracts/DomainSale.sol';


// A seller that acts like a normal DomainSale seller but throws
// rather than accepting payment
contract MaliciousSeller {

    // Receive funds in constructor
    function MaliciousSeller() payable {
    }

    // Refuse to receive funds
    function () payable {
        revert();
    }

    // Transfer an ENS domain
    function transfer(Registrar registrar, string name, address to) {
        registrar.transfer(keccak256(name), to);
    }

    // Offer a domain for sale
    function offer(DomainSale domainSale, string name, uint256 price, uint256 reserve, address referrer) {
        domainSale.offer(name, price, reserve, referrer);
    }
}
