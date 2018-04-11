
import "DecayingTokenBoundary.sol";
import "TimeDecayingTokenEnvironment.sol";
import "TimeDecayingTokenBoundaryRange.sol";


contract TimeDecayingTokenBoundary is DecayingTokenBoundary {


    function(){
	throw;
    }

    
    function TimeDecayingTokenBoundary(
	uint256 _startDate, 
	uint256 _endDate, 
	uint256 _startPercent, 
	uint256 _endPercent, 
	address _tokenFunction){	   
                
	TimeDecayingTokenBoundaryRange defaultRange = new TimeDecayingTokenBoundaryRange(_startDate, _endDate, _startPercent, _endPercent, _tokenFunction);
	addRange(defaultRange);
    }
    
    
    
    function findActiveRange(address _environment) constant public returns (address range, bool foundAnActiveRange){	
	TimeDecayingTokenEnvironment timeEnvironment = TimeDecayingTokenEnvironment(_environment);
	
	TimeDecayingTokenBoundaryRange returnRange;
	foundAnActiveRange = false;
	
	TimeDecayingTokenBoundaryRange closestExitedRange;
	bool foundAnExitedRange = false;
	uint256 closestExitedRangeDistance = 0;
	
	for(uint256 i = 0; i < ranges.length; i++){
	  returnRange = TimeDecayingTokenBoundaryRange(ranges[i]);
	  
	  if((returnRange.startDate() <= timeEnvironment.currentTime()) && (returnRange.endDate() >= timeEnvironment.currentTime())){
	    foundAnActiveRange = true;
	    break;
	  }else{
	    if(foundAnExitedRange && (returnRange.endDate() < timeEnvironment.currentTime())){
	      uint256 currentExitedRangeDistance = (timeEnvironment.currentTime() - returnRange.endDate());
	      if(currentExitedRangeDistance < closestExitedRangeDistance){		
		closestExitedRange = returnRange;
		closestExitedRangeDistance = currentExitedRangeDistance;
	      }
	    }else{
	      if(returnRange.endDate() < timeEnvironment.currentTime()){
		foundAnExitedRange = true;
		closestExitedRange = returnRange;
		closestExitedRangeDistance = (timeEnvironment.currentTime() - returnRange.endDate());
	      }
	    }
	  }
	}
	
	if(foundAnActiveRange){
	  return (address(returnRange), foundAnActiveRange);
	}else{
	  if(foundAnExitedRange){
	    return (address(closestExitedRange), foundAnExitedRange);
	  }else{
	    return (address(returnRange), foundAnActiveRange);
	  }
	}
    }
    
    



}
