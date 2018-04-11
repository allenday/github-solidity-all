import "DecayingTokenFunction.sol";


contract StairStepDecayingTokenFunction is DecayingTokenFunction {


    function(){
	    throw;
    }
    
    
    function StairStepDecayingTokenFunction(){
    }


    function getFunctionType() constant external returns (uint8 functionType){
	return uint8(TokenFunctionType.StairStep);
    }
    
    
    function executeDecayFunction(uint256 _amount, int256 _rangeLength, int256 _distanceInRange, uint256 _startPercent, uint256 _endPercent) constant public returns (uint256 decayedAmount){
        return 222222;
    } 
    
}