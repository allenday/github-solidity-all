import "GovContracts.sol";

contract Payouts is GovContracts {

function calculatePayout(uint contractId, uint milestoneId, Constraint constraint) returns (uint payout){
    payee = msg.sender;
    vote = contracts[contractId].milestones[milestoneId].Votes[constraint];
    payout = 0;
    
    if(vote.resolved == true){
        uint winningVotes;
        uint losingVotes;
        uint originalContribution;

        if(vote.globalVote.positive > vote.globalVote.negative){
            //positives won
            winningVotes = vote.globalVote.positive;
            losingVotes = vote.globalVote.negative;
            originalContribution = contracts[contractId].milestones[milestoneId].Votes[constraint].vote[payee].positive;
        }
        else{
            //negatives won
            winningVotes = vote.globalVote.negative;
            losingVotes = vote.globalVote.positive;
            originalContribution = contracts[contractId].milestones[milestoneId].Votes[constraint].vote[payee].negative;
        }
        //calculate payout
        uint individualPayout = 0;
        individualPayout = originalContribution * (1+ losingVotes/winningVotes);
    }
    return payout;
}

function payout (uint contractId, uint milestoneId, Constraint constraint) private {
    payee = msg.sender;
    uint payout = calculatePayout(contractId, milestoneId, constraint);
    if(payout > 0){
        //zero out account so that the sender cannot payout more than once
        contracts[contractId].milestones[milestoneId].Votes[constraint].vote[payee].negative = 0;
        contracts[contractId].milestones[milestoneId].Votes[constraint].vote[payee].positive = 0;
        if(!payee.send(payout)){
            throw; //if we can't pay out then throw will revert the account changes above
        }
    }
}

function payoutForTimeline(uint contractId, uint milestoneId){
    payout(contractId, milestoneId, Constraint.Timeline);
}
function payoutForBudget(uint contractId, uint milestoneId){
    payout(contractId, milestoneId, Constraint.Budget);
}

}