contract Reputation {

  address owner = 0x8344A845B76c02797Fbf3185Cc852957d148b8c3; //hardcoded as geth node stopped working and metamask doesn't allow imports

  modifier paid() {
    if(msg.value != 0.0001 ether) throw;
    else owner.send(msg.value / 95); //5% fee
     _;
  } //prevents spam and pays a small fee

  struct profile {
    uint positive;
    uint negative;
    uint total;
    string username;
    string location;
    string [] messages;
    address [] traders;
    bool [] givenReputation;
    uint burnedCoins;
    uint burnedBitcoin;
  }

  mapping (address => profile) users;

  event _positiveReputation(address indexed user, string indexed message);
  event _negativeReputation(address indexed user, string indexed message);
  event _addUser(string indexed username, string indexed location, address indexed user);
  event _newTrade(address indexed vendor, address indexed buyer);
  event _viewedReputation(address indexed user, uint indexed positive, uint indexed negative
  ,uint total, uint burnedEth, uint burnedCoins);

  function(){ if(msg.value != 0.001 ether) throw; } //if not paying the fee then throw and refund

  function addUser(string username, string location) returns (string) {
    users[msg.sender].positive = 0;
    users[msg.sender].negative = 0;
    users[msg.sender].total = 0;
    users[msg.sender].username = username;
    users[msg.sender].location = location;
    _addUser(username,location,msg.sender);
    return username;
  }

  function trade(address vendor) {
      if(msg.sender != vendor){
          users[vendor].traders.push(msg.sender);
          users[vendor].givenReputation.push(false);
          _newTrade(vendor,msg.sender);
      }
  }

  function giveReputation(address vendor, bool isPositive, string message) {
    for(uint i = 0; i < users[vendor].traders.length; i++){
      if(users[vendor].traders[i] == msg.sender
      && users[vendor].givenReputation[i] == false){
        if(isPositive){
          users[vendor].positive ++;
          users[vendor].messages.push(message);
           _positiveReputation(vendor,message);
        }
        else{
          users[vendor].negative ++;
          users[vendor].messages.push(message);
          _negativeReputation(vendor,message);
        }
      }
    }
  }

  function viewReputation(address user) returns (uint, uint, uint, uint, uint){
    _viewedReputation(user, users[user].positive, users[user].negative,
    users[user].total,users[user].burnedCoins, users[user].burnedBitcoin);
    return(users[user].positive, users[user].negative, users[user].total,
    users[user].burnedCoins, users[user].burnedBitcoin);
  }

}
