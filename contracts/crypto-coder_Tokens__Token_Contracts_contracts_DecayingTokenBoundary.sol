

contract DecayingTokenBoundary {

    
    function findActiveRange(address _environment) constant public returns (address range, bool foundAnActiveRange);

    
    function addRange(address _range) returns (uint256 rangeIndex){
	uint256 newRangeIndex = ranges.push(_range);	
	return newRangeIndex;
    }
    
    function removeRange(uint256 _rangeIndex) returns (bool success){
	if(ranges.length > _rangeIndex && 0 <= _rangeIndex){
	    for(uint256 i = _rangeIndex; i < ranges.length - 1; i++){
		ranges[i] = ranges[i+1];
	    }
	    delete ranges[ranges.length-1];
	    ranges.length--;
	    
	    return true;
	}else{
	    return false;
	}   
    }    


    address[] internal ranges;
}
