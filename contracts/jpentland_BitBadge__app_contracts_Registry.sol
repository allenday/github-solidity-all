contract Registry {

    struct Domain {
        mapping (string => User) users;
    }
    
    struct User {
        bool exists;
        address addr;
        string proof;
    }

    mapping (string => Domain) domains;

    function Registry(){
        // Do nothing
    }
    
    /* Register a new identity in the contract */
    function registerIdentity(string username, string domain, string proof) {
        Domain d = domains[domain];
        User u = d.users[username];
        
        u.addr = msg.sender;
        u.proof = proof;
        u.exists = true;
    }
    
    /* Delete an identity from the contract */
    function deleteIdentity(string username, string domain) {
        Domain d = domains[domain];
        User u = d.users[username];
 
        if( !u.exists)
            return;
            
        if( u.addr != msg.sender)
            return;
            
        u.exists = false;
    }
    
    /* Get address from username and domain */
    function getAddr(string username, string domain) returns (address addr) {
        Domain d = domains[domain];
        User u = d.users[username];
        addr = u.addr;
        
        return addr;
    }
    
    /* Get proof from username and domain */
    function getProof(string username, string domain) returns (string proof) {
        Domain d = domains[domain];
        User u = d.users[username];
        proof = u.proof;
        
        return proof;
    }
    
