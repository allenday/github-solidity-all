pragma solidity ^0.4.4;
import "./BaseFareCalculator.sol";
import "./Discount.sol";
contract AutoFareCalculator is BaseFareCalculator, Discount {
  function AutoFareCalculator() {
    // constructor
  }

  function calculateFare(string source,string destination) public returns (uint256){
    return 250;
  }

  function secret() private {

  }

}
