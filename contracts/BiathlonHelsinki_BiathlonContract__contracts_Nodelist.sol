pragma solidity ^0.4.4;
import "../contracts/BiathlonNode.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Nodelist is Ownable  {
  bool public current;
  struct Entry  {
    address addr;
    string name;
    bool active;
    address migrated;
  }
  mapping(address => Entry) public entries;
  mapping(address => address) public users;



  function Nodelist() public {
    current = true;
  }

  Entry[] public nodes;
  address[] public user_list;

  event RegisterBiathlonNode(address addr);
  event RegisterBiathlonUser(address addr);
  event UpgradeNode(address from, address to, string n);
  event UpgradeNodelist(address from, address to);

  function look_for_node(address addr) public constant returns(string name, bool active, address migrated) {
    if (entries[addr].addr != address(0)) {
      return (entries[addr].name, entries[addr].active, entries[addr].migrated);
    } else {
      return ('none', false, address(0));
    }
  }

  function is_current() public constant returns(bool) {
    return current;
  }
  function count_nodes() public constant returns(uint) {
    return nodes.length;
  }

  function count_users()  public constant returns(uint) {
    return user_list.length;
  }

  function register_node(string _name) public returns(address addr, string name) {
    require(keccak256(_name) != keccak256(''));
    require(keccak256(entries[msg.sender].name) == keccak256(''));
    Entry memory this_node = Entry(msg.sender, _name, true, address(0));
    entries[msg.sender] = this_node;
    nodes.push(this_node);
    RegisterBiathlonNode(msg.sender);
    return (this_node.addr, this_node.name);

  }

  function upgrade_self(address _to) onlyOwner public returns(bool) {
    // Allow this nodelist contract itself to migrated
    // Go through every node and set their node_address to the new one
    for(uint i = 0; i<nodes.length; i++) {
      BiathlonNode n = BiathlonNode(nodes[i].addr);
      n.change_nodelist(_to);
    }
    UpgradeNodelist(this, _to);
    current = false;
  }

  function upgrade_node(address _from, address _to, string _newname) public returns(bool) {
    /* check that the _from node owner is doing this */
    BiathlonNode old_node = BiathlonNode(_from);
    require(old_node.owner() == msg.sender);

    require(entries[_from].addr != address(0));
    entries[_from].active = false;
    entries[_from].migrated = _to;
    Entry memory new_node = Entry(_to, _newname, true, address(0));
    // now let's replace the struct in the tokenlist with more active info
    for(uint i = 0; i<nodes.length; i++) {
      if(nodes[i].addr == _from) {
        nodes[i] = new_node;
        entries[_to] = new_node;
        UpgradeNode(_from, _to, _newname);
      }
    }
    // update user lists
    for(i = 0; i< user_list.length; i++) {
      if(user_list[i] == _from) {
        user_list[i] = _to;
      }
    }
    // transfer tokens

    old_node.transfer_token_ownership(_to);
    return true;
  }

  function find_and_or_register_user(address _addr, address _registrar) external returns(address) {

    if (users[_addr]==address(0)) {
      users[_addr] = _registrar;
      RegisterBiathlonUser(_addr);
      user_list.push(_addr);
      return _registrar;
    } else {
      return _addr;
    }


  }

}
