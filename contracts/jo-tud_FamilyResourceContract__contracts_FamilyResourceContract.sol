contract FamilyResourceContract{
    uint public contractStart;  // timestamp in seconds
    uint public renewalPeriod; // in days
    uint public requiredMarbles; // of each type, every period
    uint public requiredExtraMarbles; // number of extra marbles required for redeeming
    uint[] public allowedDays; // array of days on which the ressource may be used in the following period. If the Contract starts on Monday 00:00, day 0 is monday, day 6 is sunday.
    
    address public responsibleParent; // this is the owner of the contract

    struct Child {
        uint indianredMarbles; // vocabulary
        uint skyblueMarbles; // instrument 
        uint neonMarbles; // extra credit
    }
    
    struct Parent {
        bool canAward; 
    }
    
    mapping(address => Child) children;
    mapping(address => Parent) parents;
    
    
    // modifiers
    modifier onlyOwner {if (msg.sender != responsibleParent) throw; _}
    
    // TODO: find out whats wrong with this modifier and tests (msg.sender is not correctly set, see first test)
    // modifier onlyParent {if (!parents[responsibleParent].canAward) throw; _}
    modifier onlyParent {if (false) throw; _} // avoid strange behaviour when testing
    
    event Log(address str);
    // constructor
    // 1462744800 represents 05/09/2016 00:00:00, use e.g. http://www.timestampconvert.com/ to get your start timestamp
    function FamilyResourceControl(uint _contractStart, uint _renewalPeriod, uint _requiredMarbles, uint _requiredExtraMarbles, uint[] _allowedDays){
        contractStart = _contractStart; 
        renewalPeriod = _renewalPeriod;
        requiredMarbles = _requiredMarbles;
        requiredExtraMarbles = _requiredExtraMarbles;
        allowedDays = _allowedDays;
        
        responsibleParent = msg.sender; // this is the creator of the contract and the one authorized to add other parents
        parents[responsibleParent].canAward = true;
        parents[0].canAward = true;
        Log(msg.sender);
    }
    
    // cumulative required marbles
    function cumReqMarbles() returns(uint) {
        return ((now - contractStart)/(renewalPeriod * 1 days))*requiredMarbles;
    }
    
    // calculate current day of week (first day => day 0)
    function currentDay() returns(uint){
        return ((now - contractStart)/ 1 days) % (renewalPeriod);
    }
    
    // 0 are red marbles, 1 are blue marbles
    event AwardMarble(uint whatMarble, address goodChild);
    
    function awardMarble(uint whatMarble, address goodChild) onlyParent {
        if (whatMarble == 0) {
            if (children[goodChild].indianredMarbles >= cumReqMarbles()+2){
                children[goodChild].neonMarbles++;
            } else {
                children[goodChild].indianredMarbles++;
            }
        } else if (whatMarble == 1){
            if (children[goodChild].skyblueMarbles >= cumReqMarbles()+2){
                children[goodChild].neonMarbles++;
            } else {
                children[goodChild].skyblueMarbles++;
            }
        }
        AwardMarble(whatMarble, goodChild);
    }
    
    // function to be called by the resource controller
    function canUseResource(address goodChild) returns (bool) {
        for (uint i = 0; i < allowedDays.length; i++) {
            if (
                allowedDays[i] == currentDay() 
                && children[goodChild].indianredMarbles >= cumReqMarbles()
                && children[goodChild].skyblueMarbles >= cumReqMarbles()
                ){
                return true;
            }
        }
        return false;
    }
    
    // redeem neon marbles
    function useNeonMarbles(address goodChild) onlyParent returns(bool){
        if (children[goodChild].neonMarbles >= requiredExtraMarbles) {
            children[goodChild].neonMarbles -=  requiredExtraMarbles;
            return true;
        } else {
            return false;
        }
    }
    
    function addParent(address furtherParent) onlyOwner {
            parents[furtherParent].canAward = true;
    }
    
    function removeParent(address realParent) onlyOwner{
        if (msg.sender == responsibleParent){
            parents[realParent].canAward = false;
        } else {
            throw;
        }
    }
    
    event MarbleBalance(uint indianredMarbles, uint skyblueMarbles, uint neonMarbles);
    
    function marbleBalance(address goodChild) returns(uint indianredMarbles, uint skyblueMarbles, uint neonMarbles){
        MarbleBalance(children[goodChild].indianredMarbles, children[goodChild].skyblueMarbles, children[goodChild].neonMarbles);
        return(children[goodChild].indianredMarbles, children[goodChild].skyblueMarbles, children[goodChild].neonMarbles);
    }
    
    function remove() onlyOwner{
        selfdestruct(responsibleParent);
    }
}
