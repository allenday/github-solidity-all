contract SimpleDataMarket {

  struct Purchase {
    uint startTime;
  }

  // This struct keeps all data for a Record.
  struct Record {
    // Keeps the address of this record creator.
    address owner;
    // Keeps the time when this record was created.
    uint time;
    // Keeps the index of the keys array for fast lookup
    uint keysIndex;
    string desc;
    bool active;
    string help;
    address payTo;
    uint secondsLength;
    uint256 price;
    mapping (address => Purchase) purchases;
    uint vault;
  }

  // This mapping keeps the records of this Registry.
  mapping(string => Record) records;

  // Keeps the total numbers of records in this Registry.
  uint public numRecords;

  // Keeps a list of all keys to interate the records.
  string[] private keys;

  event NewSensor(string key, string desc, string help, uint secondsLength, uint price);

  // This is the function that actually insert a record.
  function register(string key, string desc, bool active, string help, address payTo, uint secondsLength, uint price) {
    if (records[key].time == 0) {
      records[key].time = now;
      records[key].owner = msg.sender;
      records[key].keysIndex = keys.length;
      keys.length++;
      keys[keys.length - 1] = key;
      records[key].desc = desc;
      records[key].active = active;
      records[key].help = help;
      records[key].payTo = payTo;
      records[key].secondsLength = secondsLength;
      records[key].price = price;
      records[key].purchases[msg.sender] = Purchase(99999999999 ether); // unlimited access to owner

      numRecords++;

      NewSensor(key, desc, help, secondsLength, price);
    }
  }

  // Updates the values of the given record.
  function update(string key, string desc, bool active, string help, address payTo, uint secondsLength, uint256 price) {
    // Only the owner can update his record.
    if (records[key].owner == msg.sender) {
      records[key].desc = desc;
      records[key].active = active;
      records[key].help = help;
      records[key].payTo = payTo;
      records[key].secondsLength = secondsLength;
      records[key].price = price;
    }
  }

  // Unregister a given record
  function toggleActive(string key) {
    Record r = records[key];
    if (r.owner == msg.sender)
    r.active = !r.active;
  }

  // Tells whether a given key is registered.
  function isRegistered(string key) constant returns(bool) {
    if (records[key].time == 0) {
      return false;
    }
    return true;
  }

  function getRecordAtIndex(uint rindex) constant returns(string key, address owner, uint time, string desc, bool active, string help, address payTo, uint secondsLength, uint256 price) {
    Record record = records[keys[rindex]];
    key = keys[rindex];
    owner = record.owner;
    time = record.time;
    desc = record.desc;
    active = record.active;
    help = record.help;
    payTo = record.payTo;
    secondsLength = record.secondsLength;
    price = record.price;
  }

  function getRecord(string key) constant returns(address owner, uint time, string desc, bool active, string help, address payTo, uint secondsLength, uint256 price) {
    Record record = records[key];
    owner = record.owner;
    time = record.time;
    desc = record.desc;
    active = record.active;
    help = record.help;
    payTo = record.payTo;
    secondsLength = record.secondsLength;
    price = record.price;
  }

  // Returns the owner of the given record. The owner could also be get
  // by using the function getRecord but in that case all record attributes
  // are returned.
  function getOwner(string key) constant returns(address) {
    return records[key].owner;
  }

  // Returns the registration time of the given record. The time could also
  // be get by using the function getRecord but in that case all record attributes
  // are returned.
  function getTime(string key) constant returns(uint) {
    return records[key].time;
  }

  // Returns the total number of records in this registry.
  function getTotalRecords() constant returns(uint) {
    return numRecords;
  }

  // Deposits money into the contract to buy access to sensor data
  // New data can only be added when previous purchase is ended
  // TODO Avoids overwriting already purchased sensordata.
  // TODO only take the needed amount
  function buyAccess(string key) {
    Record r = records[key];
    if (r.price == msg.value) {
      r.purchases[msg.sender] = Purchase(now);
      r.vault += msg.value;
    } else {
        if (!msg.sender.call.value(msg.value)())
            throw;
    }
  }

  function checkAccess(string key, address _buyer) constant returns (bool access) {
    Record r = records[key];

    uint start = r.purchases[_buyer].startTime;
    if (start == 0) return false; // No purchase exists

    if ((start + r.secondsLength) > now)
      return true;
    return false;
  }

  function withdraw(string key) {
    if (msg.sender == records[key].owner) {
      uint earnings = records[key].vault;
      records[key].vault = 0; // In this order to be sure ledger is set to 0 BEFORE transfering the money. DAO bug
            if (!msg.sender.call.value(earnings)())
                throw;
    }
  }

  function balance(string key) constant returns (uint balance) {
    if (msg.sender == records[key].owner) {
      return records[key].vault;
    }
  }

  function() {}
}