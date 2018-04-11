pragma solidity ^0.4.4;

contract will {
  address ownerAddress;
  bytes willData;


  function will() {
    // constructor
  }

  // event WillUpdate (
  //   address indexed _from,
  //   bytes indexed uploadedText
  // );

  function setWillContents(address owner, bytes uploadedText) {
    ownerAddress = owner;
    willData = uploadedText;
    // WillUpdate(msg.sender, uploadedText);
  }
  
  function getWillData() constant returns (bytes) {
    return willData;
  }

}
