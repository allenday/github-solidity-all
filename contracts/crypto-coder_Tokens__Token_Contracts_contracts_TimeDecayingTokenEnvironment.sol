
import "DecayingTokenEnvironment.sol";

contract TimeDecayingTokenEnvironment is DecayingTokenEnvironment {

    uint256 public currentTime;

    function(){
	throw;
    }
    
    function TimeDecayingTokenEnvironment(uint256 _currentTime){
	currentTime = _currentTime;
    }
    
    
}