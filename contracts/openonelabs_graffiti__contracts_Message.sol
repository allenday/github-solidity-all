pragma solidity ^0.4.11;


contract Message {

  // declare storage object
  bytes[] messages;

  // declare reference number for current message index
  uint256 public messageIndex = 0;

  // declare owner
  address private owner;

  // declare fee
  uint256 private currentFee = 50000000000000; // ~ $.01 at time of writing

  // create listener to return latest index
  event logIndex(uint256 index);

  // constructor
  function Message(){
    owner = msg.sender;
  }

  // function modifier onlyOwner
  modifier onlyOwner {
    require(msg.sender == owner);
     _;
  }

  // change tax amount (only owner)
  function changeFee(uint256 fee) onlyOwner {
    require(fee <= currentFee);  // only lower the fee

    currentFee = fee;
  }

  // change owner
  function changeOwner(address newOwner) onlyOwner {
    owner = newOwner;
  }

  // function post
  function post(bytes message) payable{
    // check to make sure the sent amount is >= current fee
    require(msg.value >= currentFee);

   // pay tax to owner
    owner.transfer(currentFee);
  
   // write to storage
    messageIndex = messages.push(message);
    
    // return the index
    logIndex(messageIndex);
  }

  // get post by id
  function getPost(uint256 index) constant returns (bytes post) {
    return messages[index];
  }   

}
