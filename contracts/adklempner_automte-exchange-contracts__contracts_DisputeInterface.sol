pragma solidity ^0.4.11;

import "./zeppelin/ownership/Ownable.sol";
import "./EZEtherMarketplace.sol";

contract DisputeInterface is Ownable {

  EZEtherMarketplace market;

  function setMarketplace(address _market) onlyOwner {
    market = EZEtherMarketplace(_market);
  }

  function setDisputed(address seller, string uid) onlyDisputeResolver {
    market.setDisputed(seller, uid);
  }

  function resolveDisputeSeller(string uid, address seller) onlyDisputeResolver {
    market.resolveDisputeSeller(seller, uid);
  }

  function resolveDisputeBuyer(string uid, address seller) onlyDisputeResolver {
    market.resolveDisputeBuyer(seller, uid);
  }

  modifier onlyDisputeResolver {
    require(msg.sender == market.disputeResolver());
    _;
  }

}
