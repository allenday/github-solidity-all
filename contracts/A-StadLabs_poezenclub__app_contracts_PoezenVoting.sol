contract PoezenVoting {
    uint public votingStart;
    uint public votingEnd;
    address owner;

 function PoezenVoting(uint _votingStart,
                            uint _votingEnd
                           )
    {
        votingStart = _votingStart;
        votingEnd = _votingEnd;
        owner = msg.sender;
    }

    event VoteAdded();

    mapping(uint => uint) public voteresults;

    // It will represent a single voter.
    struct Voter
    {
        uint vote;   // index of the voted proposal
        uint voteTime;   // timestamp of vote
    }
    mapping(address => Voter) public voters;

    function setinterval(uint start,uint end){
        //if (msg.sender == owner){
            votingStart = start;
            votingEnd = end;        
        //}
    }

    function vote(uint vote) returns (uint returnCode){

        // check if voting is active
        if (now < votingStart || now > votingEnd){
            return 1;
        }

        if (voters[msg.sender].vote == 0){
            // case : user did not vote yet
            voteresults[vote]++;
            voters[msg.sender] = Voter(vote,now);
            VoteAdded();
            return 2;
        }else{
            // user already voted - and changes his vote
            voteresults[voters[msg.sender].vote]--;
            voteresults[vote]++;
            voters[msg.sender] = Voter(vote,now);
            VoteAdded();
            return 3;
        }        
    }

}           