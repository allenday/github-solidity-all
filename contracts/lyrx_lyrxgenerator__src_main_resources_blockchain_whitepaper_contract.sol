contract Book {
  uint minPrice;        // price of the book 
  string eBookHash;  // hash identifier of the book
  address author;    // author of the book
  address editor;    // editor of the book
  address shop;      // shop selling the book
  uint copies;       // number of copies to be sold

  function fee(address who,uint aValue) returns (uint aFee){
    //Calculate the percentage of the paid price that needs to be sent
    // to the address
    [...]//Implementation skipped 
    return aFee;
  }

  //Transfer a digital copy to another smart contract
  function transferCopyFrom(address otherContract){
    [...]///Implementation skipped
  }


  function buy(){
    if(msg.value < minPrice) throw; //Not enough money sent, abort.

    if(copies < 1 ) throw;  // This book is sold out

    //Pay the parties involved, according to the contract negotiated
    author.send(fee(author,ms.value))
    editor.send(fee(editor,ms.value))
    shop.send(fee(shop,ms.value))

    //Reduce the number of available copies
    copies = copies -1 }} 

