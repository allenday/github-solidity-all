
import "StandardToken.sol";
import "DecayingTokenFunction.sol";
import "DecayingTokenBoundary.sol";
import "DecayingTokenBoundaryRange.sol";



contract DecayingToken is StandardToken {


    string public name;                   		//fancy name: eg Simon Bucks
    uint8 public decimals;                		//How many decimals to show. 
    string public symbol;                 		//An identifier: eg SBX
    string public version = 'D0.1';       		//decay 0.1 standard. Just an arbitrary versioning scheme.
    
        
    
    
    
    function addBoundary(address _newBoundary) public returns (uint256 decayBoundaryIndex){
	uint256 boundaryIndex = boundaries.push(_newBoundary);
	return boundaryIndex;
    }
    
    function removeBoundary(uint256 _decayDefinitionIndex) returns (bool success){
	if(boundaries.length > _decayDefinitionIndex && 0 <= _decayDefinitionIndex){
	    for(uint256 i = _decayDefinitionIndex; i < boundaries.length - 1; i++){
		boundaries[i] = boundaries[i+1];
	    }
	    delete boundaries[boundaries.length-1];
	    boundaries.length--;
	    
	    return true;
	}else{
	    return false;
	}    
    }
    
    
    function decayedBalanceOf(address _environment) constant public returns (uint256 decayedBalance){
	return decayedBalanceOf(msg.sender, _environment);
    }
    
    
    function decayedBalanceOf(address _owner, address _environment) constant public returns (uint256 decayedBalance){
	uint256 currentBalance = balanceOf(_owner);
	bool decayRangeFound = false;
			
	for(uint256 i = 0; i < boundaries.length; i++){	 
	    var (range, foundAnActiveRange) = DecayingTokenBoundary(boundaries[i]).findActiveRange(_environment);
	    if(foundAnActiveRange){
		decayRangeFound = true;
		decayedBalance = DecayingTokenBoundaryRange(range).calculateDecayedBalance(currentBalance, _environment);
	    }else{
		continue;
	    }
	}
	
	if(decayRangeFound){
	  return decayedBalance;
	}else{
	  return 0;
	}
    }  
    
    
    function decayedTransfer(address _to, uint256 _decayedValue, address environment) returns (bool success) {
	uint256 decayedBalance = decayedBalanceOf(msg.sender, environment);    
        if (decayedBalance >= _decayedValue && _decayedValue > 0) {
	    uint256 transferAmount = (balanceOf(msg.sender) / decayedBalance) * _decayedValue;
	    success = transfer(_to, transferAmount);
            return success;
        } else { return false; }
    }

    function decayedTransferFrom(address _from, address _to, uint256 _decayedValue, address environment) returns (bool success) {
	uint256 decayedBalance = decayedBalanceOf(_from, environment); 
	uint256 transferAmount = (balanceOf(_from) / decayedBalance) * _decayedValue;   
        if (decayedBalance >= _decayedValue && allowed[_from][msg.sender] >= transferAmount && _decayedValue > 0) {
	    success = transferFrom(_from, _to, transferAmount);
            return success;
        } else { return false; }
    }
    
    
    address[] internal boundaries;
}





