
import "DecayingToken.sol";


contract TimeDecayingToken is DecayingToken {

    function(){
	throw;
    }
    
    function TimeDecayingToken(
	address _tokenBoundary, 
	uint256 _initialAmount,
	string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol){
        
        balances[msg.sender] = _initialAmount;     
        totalSupply = _initialAmount;                        
        name = _tokenName;                                  
        decimals = _decimalUnits;  
        symbol = _tokenSymbol;    
        
	addBoundary(_tokenBoundary);
    }
}

