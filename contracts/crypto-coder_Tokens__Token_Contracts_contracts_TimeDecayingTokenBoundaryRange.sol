

import "DecayingTokenBoundaryRange.sol";
import "TimeDecayingTokenEnvironment.sol";


contract TimeDecayingTokenBoundaryRange is DecayingTokenBoundaryRange {

    uint256 public startDate;
    uint256 public endDate;


    function(){
	throw;
    }

    
    function TimeDecayingTokenBoundaryRange(
	uint256 _startDate, 
	uint256 _endDate, 
	uint256 _startPercent, 
	uint256 _endPercent, 
	address _tokenFunction){
	
	if(_startDate >= _endDate){ throw; }
	if(_startPercent < _endPercent){ throw; }
	
	startDate = _startDate;
	endDate = _endDate;
	startingPercent = _startPercent;
	endingPercent = _endPercent;
	tokenFunction = _tokenFunction;  
    }

    
    function calculateRangeLength() constant public returns (int256 rangeLength){
	return int256(endDate-startDate);
    }
    
    
    function calculateCurrentDistanceInRange(address _environment) constant public returns (int256 distanceInRange){
	int256 rangeLength = calculateRangeLength();
	
	TimeDecayingTokenEnvironment timeEnvironment = TimeDecayingTokenEnvironment(_environment);
	if(timeEnvironment.currentTime() >= endDate){
	  return rangeLength;
	}else{
	  if(timeEnvironment.currentTime() <= startDate){
	    return 0;
	  }else{
	    return int256(timeEnvironment.currentTime() - startDate);
	  }
	}	  
    }
    
    
    
    
    

}