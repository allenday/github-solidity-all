
import "DecayingTokenFunction.sol";


contract DecayingTokenBoundaryRange {

    uint256 internal startingPercent;	//Number from 0 to 100 indicating the range start percent decay
    uint256 internal endingPercent;	//Number from 0 to 100 indicating the range end percent decay
    address internal tokenFunction;    
   
    
        
    function calculateDecayedBalance(uint256 _balance, address _tokenEnvironment) constant public returns (uint256 decayedBalance){
	int256 rangeLength = calculateRangeLength();			
	int256 distanceInRange = calculateCurrentDistanceInRange(_tokenEnvironment);
				
	uint256 returnBalance = DecayingTokenFunction(tokenFunction).executeDecayFunction(_balance, rangeLength, distanceInRange, startingPercent, endingPercent);
    
	return returnBalance;
    }
    
    
    function calculateRangeLength() constant public returns (int256 rangeLength);
    
    function calculateCurrentDistanceInRange(address _environment) constant public returns (int256 distanceInRange);
 
 
    
    
    
    
    
    
    
    
 
  
}