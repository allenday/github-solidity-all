contract wordCounter {
    mapping(uint => bool) verifiedTasks;
    mapping(address => bool) serverKeys;
    
    
    function wordCounter(){
        serverKeys[msg.sender] = true;
    }
    
    function verified (uint ID) public{
        if(serverKeys[msg.sender]) verifiedTasks[ID] = true;
        else throw;
    }
    
    function toggleKey(address server, bool valid){
        if(serverKeys[msg.sender]) serverKeys[server] = valid;
        else throw;

    }
    
    function validate(uint ID, bytes data) public constant returns (bool){
        return verifiedTasks[ID];
    }
    
}