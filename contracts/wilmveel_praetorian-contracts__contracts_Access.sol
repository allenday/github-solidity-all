contract Access{
    
    address ownerDelegate;
    
    address[] solvedChallenges;
    
    event success();
    event error();
    
    function Access (){
       ownerDelegate = msg.sender; 
    }
    
    function authorize(){
        solvedChallenges.push(msg.sender);
        return success();
    }
    
    function isSolved(address challenge) constant returns(address[] sc){
        return solvedChallenges;
    }
    
}