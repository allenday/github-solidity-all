contract Grant {

    address client;
    address owner;
    
    string conditions;
    
    /*
     * No Ether can be transferred to Grant
     */
    function(){
        return;
    }

    function Grant(address _client) {
        client = _client;
    }

    /*
     * authorize the grant contract
     * this can only be done once
     */
    function authorize() {
        if(msg.sender != owner) throw;
        owner = msg.sender;
    }

    /*
     * revoke the grant contract
     * this can be done by the client or owner
     */
    function revoke() {
        if(msg.sender != client ||  msg.sender != owner) throw;
        suicide(msg.sender);
    }
    
    function getState() constant returns(address client, address owner, string conditions){
        return (client, owner, conditions);
    }

}

