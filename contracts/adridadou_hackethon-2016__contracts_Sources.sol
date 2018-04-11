import "GovContracts.sol";

contract Sources is GovContracts {
     
    function addSourceForBudget(uint contractId, uint milestoneId, string hash, bool value)  {
        addSource(contractId,milestoneId,hash,value,Constraint.Budget);
    }
     
    function addSourceForTimeline(uint contractId, uint milestoneId, string hash, bool value)  {
        addSource(contractId,milestoneId,hash,value,Constraint.Timeline);
    }

    function addSource(uint contractId, uint milestoneId, string hash, bool val, Constraint constraint) private {
        //does this hash already exist?
        if(sourceReverseLookup[hash].constraint != Constraint.None){
            Source s = sourceReverseLookup[hash];
            if(s.val == val && s.constraint == constraint){
                // we already have this exact source in memory, so don't do anything
                return;
            }
            else{
                //hash exists but with different val or constraint
                //for now throw; better logic could be added later
                throw;
            }
        }
        //source does not exist yet, therefore create new source
        
        contracts[contractId].milestones[milestoneId].sources[contracts[contractId].milestones[milestoneId].nbSources] = Source({hash: hash, val: val, constraint: constraint, weight:0});
        contracts[contractId].milestones[milestoneId].nbSources++;
        sourceReverseLookup[hash] = Source({hash: hash, val: val, constraint: constraint, weight: 0});
    } 
     
    function getSourceHash(uint contractId, uint milestoneId, uint sourceId) constant returns (string){
        return contracts[contractId].milestones[milestoneId].sources[sourceId].hash;
    }
    
    function getSourceValue(uint contractId, uint milestoneId, uint sourceId) constant returns (bool){
         return contracts[contractId].milestones[milestoneId].sources[sourceId].val;
     }
     
    function getSourceConstraint(uint contractId, uint milestoneId, uint sourceId) constant returns (Constraint){
        return contracts[contractId].milestones[milestoneId].sources[sourceId].constraint;
    }
     
    function getNumberOfSources(uint contractId, uint milestoneId, Constraint constraint) constant returns (uint){
         return contracts[contractId].milestones[milestoneId].nbSources;
     }

}