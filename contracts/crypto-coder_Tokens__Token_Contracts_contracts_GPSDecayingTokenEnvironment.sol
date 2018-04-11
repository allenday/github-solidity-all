
import "DecayingTokenEnvironment.sol";

contract GPSDecayingTokenEnvironment is DecayingTokenEnvironment {

    uint256 public currentLatitude;
    uint256 public currentLongitude;

    function(){
	throw;
    }
    
    function GPSDecayingTokenEnvironment(uint256 _currentLatitude, uint256 _currentLongitude){
	currentLatitude = _currentLatitude;
	currentLongitude = _currentLongitude;
    }
    
    
    
}