contract owned {
  address owner;
  function owned() {
    owner = msg.sender;
  }
  function changeOwner(address newOwner) onlyowner {
    owner = newOwner;
  }
  modifier onlyowner() {
    if (msg.sender==owner) _
  }
}

contract Lock is owned{
  uint price;
  uint startTime;
  uint endTime;
  uint userId;

  event GrantAccess(uint userId, uint startTime, uint endTime);

  function updateRentInfo(uint _price, uint _startTime, uint _endTime) onlyowner {
    price = _price;
    startTime = _startTime;
    endTime = _endTime;
  }

  function getRentInfo() returns (uint[3]) {
    uint[3] memory arr;
    arr[0] = price;
    arr[1] = startTime;
    arr[2] = endTime;
    return arr;
  }

  function deposit(uint _userId) returns (bool) {
    if(msg.value < price) throw;

    userId = _userId;
    GrantAccess(userId, startTime, endTime);
    return true;
  }
}
