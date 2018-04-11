pragma solidity ^0.4.0;

contract MeetupContract {

  enum MeetupStatus { OPEN, CANCELED, DONE }

  address public owner;
  string public name;
  string public description;
  uint256 public amount_needed;
  uint256 public cashback;
  uint public max_participants;
  uint public min_participants;
  uint public participants_length;
  uint256 public invitation_value;
  mapping (address => bool) public participants;
  mapping (address => uint256) public balanceOf;
  MeetupStatus public status = MeetupStatus.OPEN;

  event Join(address participant);
  event Leave(address participant);
  event Withdraw(address participant);
  event Done();
  event Cancel();

  modifier onlyOwner {
    if (msg.sender != owner) throw;
    _;
  }

  modifier isOpen {
    if (status != MeetupStatus.OPEN) throw;
    _;
  }

  modifier isParticipant {
    if (!participants[msg.sender]) throw;
    _;
  }

  modifier isNotParticipant {
    if (participants[msg.sender]) throw;
    _;
  }

  function MeetupContract(string _name,
                          string _description,
                          uint _amount_needed,
                          uint _max_participants,
                          uint _min_participants) {
    owner = msg.sender;
    name = _name;
    description = _description;
    amount_needed = _amount_needed * 1 ether;
    max_participants = _max_participants;
    min_participants = _min_participants;
    invitation_value = amount_needed / min_participants;
    status = MeetupStatus.OPEN;
    participants_length = 0;
    cashback = 0;
  }

  function join() isOpen isNotParticipant payable {
    if( msg.value == invitation_value && participants_length < max_participants ){
      participants[msg.sender] = true;
      participants_length += 1;
      balanceOf[msg.sender] = msg.value;
      Join(msg.sender);
    } else {
      throw;
    }
  }

  function leave() isOpen isParticipant {
    participants[msg.sender] = false;
    participants_length -= 1;
    Leave(msg.sender);
  }

  function done() onlyOwner isOpen {
    if(participants_length >= min_participants){
      if(owner.send(amount_needed)){
        status = MeetupStatus.DONE;
        cashback = this.balance / participants_length;
        Done();
      }
    } else {
      throw;
    }
  }

  function cancel() onlyOwner isOpen {
    status = MeetupStatus.CANCELED;
    Cancel();
  }

  function withdraw() {
    if( balanceOf[msg.sender] > 0 ){
      uint256 amount = cashback;
      if( !participants[msg.sender] || status == MeetupStatus.CANCELED){
        amount = balanceOf[msg.sender];
      }
      if(amount > 0){
        if(msg.sender.send(amount)){
          balanceOf[msg.sender] = 0;
          Withdraw(msg.sender);
        }
      }
    }
  }

  function kill() onlyOwner {selfdestruct(owner);}

  function() payable {}
}
