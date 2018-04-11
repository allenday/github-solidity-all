pragma solidity ^0.4.4;

contract AaadharDemo {
  function AaadharDemo() {
    // constructor
  }

  mapping (string=>Details) aadharDetails;


  struct Details {
    string name;
    string mobileNo;
  }

  uint256 aadharCount=1;


  function registerAadharDetails(
    string name,
    string mobileNumber,
    string addharNo) {
    aadharDetails[addharNo] = Details(name,mobileNumber);
    
  }

  

}
