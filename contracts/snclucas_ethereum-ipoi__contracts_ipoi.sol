contract IPOI {
  // Idea object
  struct Idea {
    uint32 id;
    address owner;
    address[] parties;
    uint256 date;
    string description;
    bytes proofDoc;
  }

  // State variable to hold ID of next idea
  uint32 numIdeaId;
  
  //Mapping of Idea datatypes
  mapping(uint => Idea) ideas;
  
  // Maps owner to their ideas
  mapping(address => uint32[]) ownerIdeas;
  
  // Owner
  address public owner;
  
  // Fee to use the service
  uint public fee;

  //Set owner and fee
  function IPOI(uint feeParam) {
    owner = msg.sender;
    fee = feeParam;
  }
  
  // Change contract fee
  function changeContractFee(uint newFee) onlyowner {
    fee = newFee;
  }

  // Create initial idea contract
  function createIdea(address ideaOwner, address[] partiesEntry, string descriptionEntry) onlyowner returns(uint32 ideaId) {
    
    if (msg.value >= fee) {

      if (msg.value > fee) {
        msg.sender.send(msg.value - fee); //payed more than required => refund
      }

      ideaId = numIdeaId++;
      Idea idea = ideas[ideaId];
      ownerIdeas[ideaOwner].push(ideaId);
      idea.id = ideaId;
      idea.owner = ideaOwner;

      for (uint i = 0; i < partiesEntry.length; i++) {
        idea.parties.push(partiesEntry[i]); 
      }

      idea.date = now;
      idea.description = descriptionEntry;

      IdeaChangeEvent(idea.date, "IPOI Contract Creation", bytes(descriptionEntry));
    }
  }
  
  // Get idea by the address owner dadress
  function getIdea(address ideaOwner) returns(uint32[]) {
    return ownerIdeas[ideaOwner];
  }
  
  // Get idea date by ID
  function getIdeaDate(uint ideaId) returns(uint ideaDate) {
    return ideas[ideaId].date;
  }
  
  // Get idea description by ID
  function getIdeaDescription(uint ideaId) returns(string ideaDescription) {
    return ideas[ideaId].description;
  }

  // Get idea parties by ID
  function getIdeaParties(uint ideaId) returns(address[] ideaParties) {
    return ideas[ideaId].parties;
  }
  
  // Get owner of contract
  function getOwner() returns(address owner) {
    return owner;
  }
  
  
  // Upload documentation for proof of idea (signed signatures?)
  function ideaProofDocument(bytes IPOIProofHash, uint ideaId) onlyowner {
    ideas[ideaId].proofDoc = IPOIProofHash;
    IdeaChangeEvent(block.timestamp, "Entered Idea Proof Document", "Idea proof in IPFS");
  }

  // Declare event structure
  event IdeaChangeEvent(uint256 date, bytes indexed name, bytes indexed description);

  function destroy() {
    if (msg.sender == owner) {
      suicide(owner); // send any funds to owner
    }
  }
  
  modifier onlyowner() {
    if (msg.sender == owner)
      _
  }

  // This function gets executed if a transaction with invalid data is sent to
  // the contract or just ether without data. We revert the send so that no-one
  // accidentally loses money when using the contract.
  function() {
    throw;
  }
}
