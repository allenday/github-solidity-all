pragma solidity ^0.4.2;

contract tokenContract {   
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success); 
}

contract USDZAR {
    
  uint256 public rate;

  struct Approval{
    address approver;
    address tokenContract_;
    uint256 value;
    uint256 rate;
  }

  mapping (address => Approval) public approvals;

  event ApprovedExchange(
      address indexed approver
    , address indexed tokenContract_
    , uint256 indexed value
  );

  event LogAddress(address indexed address_);
  event LogValue(uint256 indexed value_);

  function USDZAR(uint256 rate_) {
    rate = rate_;
  }

  // TODO: Should approvals only be valid for a specified time?
  function addApproval(address requester, address tokenContract_, uint256 value, uint256 rate) 
    returns (bool success){

    Approval memory newApproval = Approval({
      approver: msg.sender,
      tokenContract_: tokenContract_,
      value: value,
      rate: rate
    });
    approvals[requester] = newApproval;
    ApprovedExchange(msg.sender, tokenContract_, value);
    return true;
  }

  function receiveApproval(address requester, uint256 value, address tokenContract_, bytes extraData)
    returns (bool success) {
    Approval approval = approvals[requester];
    //TODO: check that approval hasn't expired yet
    //TODO: check rate against value approved for
    tokenContract token1 = tokenContract(tokenContract_);
    tokenContract token2 = tokenContract(approval.tokenContract_);
    //TODO: add checks for success
    token1.transferFrom(requester, approval.approver, value);
    token2.transferFrom(approval.approver, requester, approval.value);
    return true;
  }

  function setRate(uint256 _value) {
    rate = _value;
  }

  function getRate() returns (uint256){
    return rate;
  }

  function () {
    throw;
  }
}
