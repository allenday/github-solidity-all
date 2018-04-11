

contract DecayingTokenFunction {
    
    enum TokenFunctionType { Sudden, Linear, StairStep, Exponential, Custom }
                  
    function getFunctionType() constant external returns (uint8 functionType);
        
    function executeDecayFunction(uint256 _amount, int256 _rangeLength, int256 _distanceInRange, uint256 _startPercent, uint256 _endPercent) constant public returns (uint256 decayedAmount);
    
    
    
}
