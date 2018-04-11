import "./api/OracleItAPI.sol";
import "./api/Utils.sol";

contract EthCnyPrice is usingOracleIt, usingUtils {
    uint public timestamp;
    uint public price; // fen
    uint public latestId;
    
    function EthCnyPrice() {
    }
    
    function queryPrice() {
        latestId = oracleItQuery("URL", "json<https://yunbi.com/api/v2/tickers/ethcny.json>.ticker.sell");
    }

    function __callback(uint id, string result) {
        if (msg.sender != oracleItCallbackAddress()) throw;
        if (latestId == id){
            timestamp = now;
            price = parseInt(result, 2);
        }
    }
}