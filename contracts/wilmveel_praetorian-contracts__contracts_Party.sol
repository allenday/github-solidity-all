contract Party {

    function Party(){}
    
    address[] challenges;
    
    function getChallenges() constant returns(address[]){
        return challenges;
    }
    
    function addChallenge(address challenge) {
        challenges.push(challenge);
    }

}
