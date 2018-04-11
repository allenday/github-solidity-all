pragma solidity ^0.4.18;

import './Ownable.sol';

contract Affiliable is Ownable {
    uint8 public affilatePercentage = 50;
    mapping (address => uint8) public verifiedAffiliatesShare;

    function updateAffiliate(address affiliateAddr, uint8 share) onlyOwner public {
        require(share <= 100);
        verifiedAffiliatesShare[affiliateAddr] = share;
    }
}