contract Blox {
  // simple mapping hash of invention to address of inventor
  mapping (string => address) inventions;
  uint public total = 0;

  // add invention
  function put(string hash) returns (bool success) {
    if (inventions[hash] == 0){
      inventions[hash] = msg.sender;
      total += 1;
      success = true;
    }
    else
      success = false;
  }

  // get inventor
  function get(string hash) returns (address inventor) {
    inventor = inventions[hash];
  }
}
