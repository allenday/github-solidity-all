contract MyToken{
  string public name;
  string public symbol;
  uint8 public decimals;

  mapping (address => uint256) public balanceOf;

  event Transfer(address indexed from, address indexed to, uint256 value);

  function MyToken(uint256 _supply, string _name, string _symbol, uint8 _decimals) {
    if (_supply == 0) _supply = 1000;
    balanceOf[msg.sender] = _supply;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }

  function transfer(address _to, uint256 _amount) {
    if (balanceOf[msg.sender] < _amount) throw;     // throw is cancelling the transaction and return the gas to the sender
    balanceOf[msg.sender] -= _amount;
    balanceOf[_to] += _amount;
    Transfer(msg.sender, _to, _amount);
  }
}
