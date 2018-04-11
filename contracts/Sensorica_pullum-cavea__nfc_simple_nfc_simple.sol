
//uid is stored without the colons to avoid HTTP problems
//Returns
//1 :success or permissions
//-1:user existence related
//-2:master is wrong

contract nfc_simple {
  address owner_addr; //Should we store sender?
  
  struct user {
    bool exists;
    bytes32 master_uid;
    int perms; //permissions: 1 is simple access, 127 is master
  }
  mapping (bytes32 => user) users;

  function nfc_simplehq() { // Constructor
     owner_addr = msg.sender;
  }

  function add_user(bytes32 uid, bytes32 m_uid, int perm) returns (int){
    if (! users[uid].exists) { 
        users[uid].exists = true;
        users[uid].master_uid = m_uid;
        users[uid].perms = perm;
        return 1;//users[uid].perms;
    }
    else return -1;

  }

  function del_user(bytes32 uid, bytes32 m_uid) returns (int) {
    if (users[uid].exists)
        if (users[uid].master_uid == m_uid) { 
            users[uid].exists = false;
            return 1;
        } else {
            return -2;
        }
    else return -1;
      
  }
  
  function modify_perms(bytes32 uid, bytes32 m_uid, int perm) returns (int){
    if (users[uid].exists)
        if (users[uid].master_uid == m_uid) { 
            users[uid].perms = perm;
            return 1;
        } else {
            return -2;
        }
    else return -1;

  }

  function get_perms(bytes32 uid) returns (int) {
      if (users[uid].exists) {
          return users[uid].perms;
      } 
      else return -1;
      
  }

  function get_master(bytes32 uid) returns (bytes32){
    if (users[uid].exists) { 
        return users[uid].master_uid;
    }
    else return -1;

  }

  function remove() {
    if (msg.sender == owner_addr){
        selfdestruct(msg.sender);
    }
  }

}


