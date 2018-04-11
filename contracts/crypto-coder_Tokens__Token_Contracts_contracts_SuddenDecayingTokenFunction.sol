import "DecayingTokenFunction.sol";

contract SuddenDecayingTokenFunction is DecayingTokenFunction {


    function(){
	    throw;
    }
    
    
    function SuddenDecayingTokenFunction(){
    }


    function getFunctionType() constant external returns (uint8 functionType){
	return uint8(TokenFunctionType.Sudden);
    }
    
    
    function executeDecayFunction(uint256 _amount, int256 _rangeLength, int256 _distanceInRange, uint256 _startPercent, uint256 _endPercent) constant public returns (uint256 decayedAmount){
        //Percentages were supplied with 2 units of precision already, so decayedAmount will need them removed with rounding
                                                
        if(_rangeLength <= 0 || _distanceInRange >= _rangeLength){
    	  decayedAmount = (_endPercent * _amount) / 100;
    	}else{
    	  decayedAmount = _amount;
	}
        
    	return decayedAmount;
    }    
    
}