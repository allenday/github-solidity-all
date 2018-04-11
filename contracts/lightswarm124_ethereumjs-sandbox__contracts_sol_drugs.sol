contract drugs {
  address public minter;
  uint256 totalSupply;
  mapping (address => uint256) public balances;
  mapping (address => bool) public MD;

  event Sent (address from, address to, uint amount);

  modifier onlyMD (address verify) {                  //Verify if MD is registered
    if (MD[verify] != true)
    throw;
    _
  }

  function approve(address physician) {
    MD[physician] = true;                             //Sets MD as registered
  }

  function drugs (uint256 initialAmount) {
    minter = msg.sender;
    balances[minter] = initialAmount;
    totalSupply = initialAmount;
  }

  function mint (address receiver, uint amount) {
    if (msg.sender != minter) return;
    balances[receiver] += amount;
  }

  function Send (address sender, address receiver, uint amount) onlyMD(sender) {
    if (balances[sender] < amount) { throw;}
    balances[sender] -= amount;
    balances[receiver] += amount;
    Sent (sender, receiver, amount);
  }

  function checkBalance (address _asker) constant returns (uint256 balance) {
    return balances[_asker];
  }

  function checkMD (address _asker) constant returns (bool MDorNo) {
    return MD[_asker];
  }
}
