pragma solidity ^0.4.4;

contract Category {

  string public Name;
  function SetCategoryName(string name) public { Name = name; }

  // TODO use future ConsentData type when that's done
  uint256[] public ConsentData;

  function GetConsentData(uint i) constant returns(uint256) { return ConsentData[i]; }
  function GetConsentDataCount() constant returns(uint256) { return ConsentData.length; }
  function AddConsentData(uint256 consentData) { ConsentData.push(consentData); }
  function GetAllConsentData() constant returns(uint256[]) { return ConsentData; }

  function Category(string name) {
    Name = name;
    ConsentData = new uint256[](0);
  }
  
}
