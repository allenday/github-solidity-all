contract PrivateLedger {

  address public owner;
  address[] members;
  bytes[] public transactions;

  modifier isOwner {
    if (msg.sender == owner) _
  }

  modifier isMember {
    for (uint i = 0; i < members.length; i++) {
      if (msg.sender == members[i]) _
    }
  }

  event NewTransaction(uint id);

  function PrivateLedger() {
    owner = msg.sender;
  }

  function addMember(address member) isOwner {
    members[members.length++] = member;
  }

  function removeMember(address member) isOwner {
    for (uint i = 0; i < members.length; i++) {
      if (member == members[i]) {
        delete members[i];
      }
    }
  }

  function getMembers() isOwner constant returns (address[]) {
    return members;
  }

  function addTransaction(bytes transaction) isMember {
    uint id = transactions.length++;
    transactions[id] = transaction;
    NewTransaction(id);
  }

  function numTransactions() constant returns (uint) {
    return transactions.length;
  }

}
