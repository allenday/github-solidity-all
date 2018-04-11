pragma solidity ^0.4.11;

// TextMessage.ETH Contract Methods
contract TextMessage {
    function sendText(string phoneNumber, string textBody) payable public;  // requires minimum wei payment
    function costWei() constant returns (uint);  // returns minimum wei amount for SMS message
}

contract example {
  uint txtCost;
  address txtAddr = 0xA221c8dF14434e700fD3af96a96b7a3B66beCAed;  // ropsten testnet
  TextMessage txt = TextMessage(txtAddr);
  
  function example() public { }
  
  function deposit() public payable {
      
  }
    
  function sendMsg() payable public {
      txtCost = txt.costWei();
      // encrypt your values at https://cjx.io/encrypt?value=18055555555
      txt.sendText.value(txtCost).gas(80000)("7b3031af5b66cf99bfe3f297467cd446", "716e01d0ecc1021a09fd27758fa377d5");
  }
  
}
