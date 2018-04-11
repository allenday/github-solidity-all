contract SimpleStorage {
  uint storedData;
  function SimpleStorage() {
    // constructor
  }
  function set(uint x) {
      storedData = x;
  }
  function get() constant returns (uint retVal) {
      return storedData;
  }
}