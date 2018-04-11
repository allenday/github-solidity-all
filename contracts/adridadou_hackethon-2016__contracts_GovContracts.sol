import "PubcrawlState.sol";

contract GovContracts is PubcrawlState{

    function buildContract(string contractHash, string name) { 
    	// Create a new government contract 
    	// BlockOne Modifer needed (only Government)
    	
    	GovContract NewContract = contracts[numberContracts];
    	NewContract.termsHash = contractHash;
        NewContract.name = name;
    	numberContracts++;

    }

    function getNumberContracts() constant returns (uint){
    	return numberContracts;
    }

    function getContractHash(uint id) constant returns (string) {
    	return contracts[id].termsHash;
    }

    function getContractName(uint id) constant returns (string) {
        return contracts[id].name;
    }

    function buildMilestone(uint govContract_id, uint duration, uint targetBudget) { 
        // Create a new milestone 
        // BlockOne Modifer needed (only Government)
        uint milestoneId = contracts[govContract_id].nbMilestones;
        Milestone NewMilestone = contracts[govContract_id].milestones[milestoneId];
        NewMilestone.contractId = govContract_id;
        NewMilestone.duration = duration;
        NewMilestone.targetBudget = targetBudget;
        contracts[govContract_id].nbMilestones++;
    }

    function getNumberMilestones(uint contractId) constant returns (uint) {
        return contracts[contractId].nbMilestones;
    }

    function getNumberSources(uint contractId, uint milestoneId) constant returns (uint) {
        return contracts[contractId].milestones[milestoneId].nbSources;
    }

    function getDuration(uint contractId, uint milestoneId) constant returns (uint) {
        return contracts[contractId].milestones[milestoneId].duration;
    }

    function getTargetBudget(uint contractId, uint milestoneId) constant returns (uint) {
        return contracts[contractId].milestones[milestoneId].targetBudget;
    }
}