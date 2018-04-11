import "DecayingTokenFunction.sol";


contract LinearDecayingTokenFunction is DecayingTokenFunction {


    function(){
	    throw;
    }
    
    
    function LinearDecayingTokenFunction(){
    }


    function getFunctionType() constant external returns (uint8 functionType){
	return uint8(TokenFunctionType.Linear);
    }
    
    
    function executeDecayFunction(uint256 _amount, int256 _rangeLength, int256 _distanceInRange, uint256 _startPercent, uint256 _endPercent) constant public returns (uint256 decayedAmount){
        //We use a max 8 total units of precision in this calculation
        //Percentages were supplied with 2 units of precision already, so we add 6 more to the the start percent
        //The _distanceInRange will get 6 units of precision, while the _rangeLength will not be adjusted
        //The decayedAmount will need to be divided to remove the 8 units of precision with rounding
                                
        uint256 scaledStartPercent = _startPercent * (10 ** 6);
        uint256 scaledDistanceInRange = uint256(_distanceInRange) * (10 ** 6);
                
        if(_rangeLength <= 0 || _distanceInRange >= _rangeLength){
    	  decayedAmount = (_endPercent * _amount) / 100;
    	}else{
    	  if(_distanceInRange <= 0){
    	    decayedAmount = (_startPercent * _amount) / 100;
    	  }else{
    	    decayedAmount = ((scaledStartPercent - ((_startPercent - _endPercent) * (scaledDistanceInRange / uint256(_rangeLength)))) * _amount);
    	    decayedAmount /= (10 ** 8);
    	  }
	}
        
    	return decayedAmount;
    } 
    
}