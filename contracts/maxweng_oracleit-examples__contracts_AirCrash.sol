import "./api/OracleItAPI.sol";
import "./api/Utils.sol";

contract AirCrash is usingOracleIt, usingUtils {
    string public flightId;
    bool public crashed;
    bool public answered;
    uint public queryId;
    
    function AirCrash() {
    }
    
    function queryAirCrash(string _flightId) {
        if(queryId == 0){
            flightId = _flightId;
            queryId = oracleItQuery("AirCrash", _flightId);
        }
    }

    function __callback(uint id, string result) {
        if (msg.sender != oracleItCallbackAddress()) throw;
        if (queryId == id){
            answered = true;
            if(parseInt(result) != 0) crashed=true;
        }
    }
}