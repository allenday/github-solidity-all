import "./api/OracleItAPI.sol";

contract Timer is usingOracleIt {
    uint public time;
    uint public times;
    uint public interval;
    bool public running;
    
    function Timer() {
        interval = 60;
    }
    
    function setInterval(uint _interval) {
        interval = _interval;
    }
    
    function startTimer() {
        if(!running){
            running = true;
            oracleItQuery(interval, "noop", "");
        }
    }

    function __callback(uint id, string result) {
        if (msg.sender != oracleItCallbackAddress()) throw;
        time = now;
        times += 1;
        oracleItQuery(interval, "noop", "");
    }
}
