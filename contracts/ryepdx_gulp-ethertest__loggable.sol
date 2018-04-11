contract Logger {
    event Log(string message);
    event LogBytes(bytes32 message);
    event LogStr(string message);
    event LogUint(uint256 message);

    function log(string message) {
        Log(message);
    }

    function logBytes(bytes32 message) {
        LogBytes(message);
    }

    function logUint(uint256 message) {
        LogUint(message);
    }

    function logStr(string message) {
        LogStr(message);
    }
}

contract Loggable is Logger {
    Logger logger;
    function Loggable() {
        logger = this;
    }

    function setLogger(address _logger) {
        logger = Logger(_logger);
    }
}
