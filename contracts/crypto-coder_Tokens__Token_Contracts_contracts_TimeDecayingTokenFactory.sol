

import "DecayingTokenFactory.sol";
import "DecayingTokenFunction.sol";
import "TimeDecayingToken.sol";
import "TimeDecayingTokenBoundary.sol";
import "TimeDecayingTokenBoundaryRange.sol";

 
contract TimeDecayingTokenFactory is DecayingTokenFactory {


    function (){
	throw;
    }
    
    
    function TimeDecayingTokenFactory(bool _useTheDefaultRegistry, address _logger){    
	if(_useTheDefaultRegistry){
	  useDefaultRegistry();
	}
	
	setLogger(_logger);
    }


    function createTimeDecayingToken(
	uint256 _startDate, 
	uint256 _endDate, 
	uint256 _startPercent, 
	uint256 _endPercent, 
	uint256 _initialAmount, 
	string _tokenName,
	uint8 _decimalUnits,
	string _tokenSymbol,
	uint8 _functionType) returns (TimeDecayingToken newTimeDecayingToken){
	
	DecayingTokenFunction tokenFunction = getTokenFunction(_functionType);
	TimeDecayingTokenBoundary tokenBoundary = new TimeDecayingTokenBoundary(_startDate, _endDate, _startPercent, _endPercent, address(tokenFunction));
	newTimeDecayingToken = new TimeDecayingToken(address(tokenBoundary), _initialAmount, _tokenName, _decimalUnits, _tokenSymbol);
	return newTimeDecayingToken;    
    }

}