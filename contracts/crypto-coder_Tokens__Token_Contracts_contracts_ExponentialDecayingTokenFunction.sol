import "math.sol";
import "DecayingTokenFunction.sol";

contract ExponentialDecayingTokenFunction is DecayingTokenFunction {


    struct ExponentialFactors{
      int256 gcd;
      int256 gcdReducedExponent;
      int8 gcdReducedRoot;
    }


    function(){
	    throw;
    }
    
    
    function ExponentialDecayingTokenFunction(){
    }


    function getFunctionType() constant external returns (uint8 functionType){
	return uint8(TokenFunctionType.Exponential);
    }
    
    
    function executeDecayFunction(uint256 _amount, int256 _rangeLength, int256 _distanceInRange, uint256 _startPercent, uint256 _endPercent) constant public returns (uint256 decayedAmount){
        //We are using fractional exponents, the equivalent of the nth root (denominator) of a number to a power (numerator)
        //Without fixed point types, our best option is to use a ratio of distance-in-range to range to have a max denominator of 100, and then round the numerator by 10s
    
        // DESIRED EXPONENTIAL FUNCTION (our implementation is a stairstep that will have 10 steps)
        // y = yMAX+1   - (((yMAX+1    ** (x/xMAX))	* (startPercent - endPercent))	/ 100)
        
        if(_distanceInRange >= _rangeLength){
            //Maximum decay, remove the entire precentage scaled amount (descaled by 100 because percent is scaled by 100) from the amount
            decayedAmount = _amount - ((_amount * (_startPercent - _endPercent)) / 100);
        }else{
            //Stairstep decay and the current step is always rounded down to the nearest 10 
            uint8 distanceRangeRatio = uint8((_distanceInRange * 100) / _rangeLength);
            uint8 currentStep = distanceRangeRatio / 10;
            
            if(currentStep == 0){
                //No decay in the first step, so use the initial percentage scaled amount (descaled by 100 because percent is scaled by 100)
                decayedAmount = ((_amount * _startPercent) / 100);
            }else{
                //For the best result, we want to execute the exponentiation before the root, but the amount must be <= 338,207,481 to prevent data type overflow
                uint256 amountDecayed = 0;
                if(_amount <= 338207481){
                    amountDecayed = _amount ** currentStep;
                    amountDecayed = uint256(math.nthRoot(int256(amountDecayed), 10));
                }else{
                    amountDecayed = uint256(math.nthRoot(int256(_amount), 10));
                    amountDecayed = amountDecayed ** currentStep;
                }
                decayedAmount = _amount - ((amountDecayed * (_startPercent - _endPercent)) / 100);
            }
        }
        
        return decayedAmount;
    }
	
    
    function oldExecuteDecayFunction(uint256 _amount, int256 _rangeLength, int256 _distanceInRange, uint256 _startPercent, uint256 _endPercent) constant public returns (uint256 decayedAmount){
    
    
    
	//This was an attempt at exponentiation using integers ... FAIL ... will require fixed-point types
	
	
        //We are trying to determine which numbers will incur the smallest exponents in the exponential functions
        //Using the ratio's will implicitly also incur a larger error in the calculation, so we want to avoid this
        //To keep results accurate, we prefer exponentiation before rooting, so check amount and exponent sizes first
        
        // y = yMAX+1   - (((yMAX+1    ** (x/xMAX))	* (startPercent - endPercent))	/ 100)
        // y = 100+1    - (((100+1     ** (160/200))	* (100 - 50))			/ 100)
        // y = 101      - (((101       ** 0.8)		* (50))				/ 100)
        // y = 101      - ((40.12888557303686099	* 50)				/ 100)
        // y = 101      - (2006.4442786518430495					/ 100)
        // y = 101      - 20.064442786518430495
        
        
        //Find the GCD for the distance and range, and get the distance reduced by the GCD
        ExponentialFactors memory distanceFactors;
        distanceFactors.gcd = math.gcd(_distanceInRange, _rangeLength);
        distanceFactors.gcdReducedExponent = int256(_distanceInRange / distanceFactors.gcd);
        distanceFactors.gcdReducedRoot = int8(_rangeLength / distanceFactors.gcd);
        
        //Find the GCD for the ratio of distance to range, and get the ratio reduced by the GCD
        int distanceRangeRatio = int((_distanceInRange * 100) / _rangeLength);
        ExponentialFactors memory ratioFactors;
        ratioFactors.gcd = int256(math.gcd(distanceRangeRatio, 100));
        ratioFactors.gcdReducedExponent = (int256(distanceRangeRatio) / ratioFactors.gcd);
	ratioFactors.gcdReducedRoot = int8(100 / ratioFactors.gcd);
        
        //Execute the exponential function as 2 steps of an exponentiation and a root. Attempt to exponentiate before rooting
        int256 amountDecayed = 0;
        int256 exponentiationResultOrderOfMagnitude = 0;
        uint8 amountOrderOfMagnitude = math.log10Ceiling(int256(_amount));
        
        if(distanceFactors.gcdReducedExponent < ratioFactors.gcdReducedExponent){	    
            exponentiationResultOrderOfMagnitude = math.log10Ceiling(amountOrderOfMagnitude ** distanceFactors.gcdReducedExponent);
            if(exponentiationResultOrderOfMagnitude <= 75){
                amountDecayed = int256(_amount+1) ** distanceFactors.gcdReducedExponent;
                amountDecayed = math.nthRoot(amountDecayed, distanceFactors.gcdReducedRoot);
            }else{
                amountDecayed = math.nthRoot(int256(_amount+1), distanceFactors.gcdReducedRoot);
                amountDecayed = amountDecayed ** distanceFactors.gcdReducedExponent;
            }
        }else{
            exponentiationResultOrderOfMagnitude = math.log10Ceiling(amountOrderOfMagnitude ** ratioFactors.gcdReducedExponent);
            if(exponentiationResultOrderOfMagnitude <= 75){
                amountDecayed = int256(_amount+1) ** ratioFactors.gcdReducedExponent;
                amountDecayed = math.nthRoot(amountDecayed, ratioFactors.gcdReducedRoot);
            }else{
                amountDecayed = math.nthRoot(int256(_amount+1), ratioFactors.gcdReducedRoot);
                amountDecayed = amountDecayed ** ratioFactors.gcdReducedExponent;
            }
        }
        
        //Range-bind the amount decayed by the start and end percent values
        //Percentages were supplied with 2 units of precision already, so remove that
        decayedAmount = (_amount+1) - ((uint256(amountDecayed) * (_startPercent - _endPercent)) / 100);
        return decayedAmount;
    } 
    
}