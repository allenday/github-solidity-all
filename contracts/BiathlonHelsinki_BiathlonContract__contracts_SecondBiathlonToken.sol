pragma solidity ^0.4.4;
import "../contracts/BiathlonNode.sol";
import "../contracts/Nodelist.sol";
import "../contracts/TokenStorage.sol";


contract SecondBiathlonToken is Ownable {

  address public node_address;
  address public storage_address;
  string public name;
  string public symbol;
  uint256 public decimals;

  uint256 public sellPrice;
  uint256 public buyPrice;
  string public standard = 'BiathlonToken 2.0';

  BiathlonNode node;
  TokenStorage token;

  event Burn(address indexed from, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event Deactivate();
  event Transfer(address indexed from, address indexed to, uint256 value);

  bool public mintingFinished = false;
  bool public active = true;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier whenActive() {
    require(active);
    _;
  }

  modifier whenInctive() {
    require(!active);
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner || msg.sender == node_address);
    _;
  }

  function SecondBiathlonToken(address _node_address, string _name, string _symbol, uint256 _decimals, address _upgradeFrom) onlyOwner public {
    node_address = _node_address;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    node = BiathlonNode(_node_address);
    if (_upgradeFrom == address(0)) {       // if 0x0 is passed as last argument, create new storage
      token = new TokenStorage(node_address);
      storage_address = token;
    } else {
      /* check that Storage is owned by this owner */
      TokenStorage check = TokenStorage(_upgradeFrom);
      /*require(check.owner() == msg.sender);*/
      token = check;
      storage_address = _upgradeFrom;
    }
    assert(msg.sender == node.owner());
  }

  function transfer_storage_ownership(address _new) onlyOwner whenActive external returns (bool) {
    token.transferOwnership(_new);
  }

  function spend(address _addr, uint256 _amount) onlyOwner whenActive external returns (bool) {
    token.subtract(_addr, _amount);
    Burn(_addr, _amount);
    return true;
  }

  function balanceOf(address _who) public constant returns (uint256) {
    return token.balanceOf(_who);
  }

  function totalSupply() public constant returns (uint256) {
    return token.totalSupply();
  }

  function deactivate() public returns(bool) {
    require(msg.sender == node_address);
    active = false;
    Deactivate();
    return true;
  }

  function mint(address _to, uint256 _amount) onlyOwner whenActive public returns (bool) {
    token.add(_to,  _amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);


    if (node.register_user(_to) ) {

      return true;
    } else {
      return false;
    }
  }

  function finishMinting() onlyOwner whenActive public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  function register_with_node() onlyOwner whenActive public returns(bool) {
    node.register_token(this, name);
    return true;
  }

  // Allow the token contract itself to transfer between users, so users don't require eth.
  // This, of course, means someone could bankrupt a node by sending tokens back and forth.
  // Security must be in place at the API/node level to prevent this (maybe by limiting the
  // # of transfers per day)?

  function biathlon_transfer(address _from, address _to, uint256 _value) onlyOwner whenActive public  returns (bool success) {
    token.transferFrom(_from, _to, _value);
    return true;
  }
}
