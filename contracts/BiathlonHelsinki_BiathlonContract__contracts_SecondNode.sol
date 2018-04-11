pragma solidity ^0.4.4;
import "../contracts/BiathlonToken.sol";
import "../contracts/Nodelist.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract SecondNode is Ownable {
  address public nodelist_address;
  string public name;
  string public location;
  Nodelist nodelist;


  struct Tokeninfo  {
    address addr;
    bool active;
    address migrated;
  }
  mapping(address => Tokeninfo) public tokens;

  Tokeninfo[] public tokenlist;
  event RegisterToken(address addr, string token_name);
  event UpgradeToken(address from, address to, string new_token_name);

  function SecondNode(address _nodelist, string _name, string _location) public {
    nodelist_address = _nodelist;
    name = _name;
    location = _location;
    nodelist = Nodelist(nodelist_address);
  }

  function get_config() external constant returns(address) {
    return nodelist_address;
  }

  function token_is_active(address _addr) public view returns(bool) {
    return tokens[_addr].active;
  }
  function count_tokens() public constant returns(uint) {
    return tokenlist.length;
  }

  function transfer_token_ownership(address _new) onlyOwner external returns (bool) {
    for(uint i = 0; i<tokenlist.length; i++) {
      if(tokenlist[i].active == true) {
        BiathlonToken t = BiathlonToken(tokenlist[i].addr);
        t.transferOwnership(_new);
      }
    }
    return true;
  }

  function register_user(address _user) public returns (bool) {
    require(nodelist.find_and_or_register_user(_user, this) != address(0));
    return true;
  }


  function change_nodelist(address _to) public returns(bool) {
    // if the nodelist is upgrade, the nodelist itself will iterate through each
    // node and call this function
    require(msg.sender == nodelist_address);
    nodelist_address = _to;
    nodelist = Nodelist(_to);
    return true;
  }


  function register_token(address _addr, string _name) public returns(address _a, string _n) {
    require(keccak256(_name) != keccak256(''));
    require(tokens[_addr].addr == address(0));
    Tokeninfo memory this_token = Tokeninfo(_addr, true, address(0));
    tokens[_addr] = this_token;
    tokenlist.push(this_token);
    RegisterToken(_addr, _name);
    return (this_token.addr,  _name);

  }

  function upgrade_token(address _from, address _to, string _name) public returns(bool) {
    require(tokens[_from].addr != address(0));
    tokens[_from].active = false;
    tokens[_from].migrated = _to;
    Tokeninfo memory new_token = Tokeninfo(_to, true, address(0));
    // now let's replace the struct in the tokenlist with more active info
    for(uint i = 0; i<tokenlist.length; i++) {
      if(tokenlist[i].addr == _from) {
        tokenlist[i] = new_token;
        tokens[_to] = new_token;

        UpgradeToken(_from, _to, _name);

      }
    }
    // deactivate original token
    BiathlonToken old_token = BiathlonToken(_from);
    old_token.transfer_storage_ownership(_to);
    old_token.deactivate();
    return true;
  }

  function register_minting(address _addr) public returns (uint) {

    nodelist.find_and_or_register_user(_addr, this);
    return nodelist.count_users();
    /*return true;*/
  }

  function connect_to_nodelist() onlyOwner public returns(bool) {
    nodelist.register_node(name);
    return true;
  }
}
