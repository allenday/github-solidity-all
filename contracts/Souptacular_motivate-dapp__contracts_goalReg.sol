contract goalReg {
    mapping (address => string) names;
    mapping(string => address) addrs;
    mapping (address => address[128]) goals;
    address motivate;
    
    function resolveName(string name) public returns (address){
        return addrs[name];
    }
    
    function resolveAddress (address addr) public returns (string){
        return names[addr];
    }
    
    function getGoals (address user) public returns (address[128]){
        return goals[user];
    }
    
    function addGoal() public returns (bool){
        if(msg.sender != motivate ){
            throw;
        }
        
        
    }
    
    
    
    
}