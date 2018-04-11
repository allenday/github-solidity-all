pragma solidity ^0.4.0;

import './Bet.sol';
import 'oraclize/usingOraclize.sol';
import './lib/StringLib.sol';

contract OraclizeBet is Bet, usingOraclize {

    function OraclizeBet() {
        OAR = OraclizeAddrResolverI(0xf90f0e95afbeb09ba392907946031b73265db5cc);
    }

    function evaluateBet() {

        // determine winner is allowed in State.Closed only
        if (state != State.Closed) {
            throw;
        }

        queryOracle(pricelevel_string, '1477440000');
    }

    function q_test(string query) {
        oraclize_query('URL', query, '{ "pair": "ETHUSD", "interval":1440, "since":1477440000}');
    }

    function queryOracle(string price, string startdate) {

        Info('Called OraclizeBet.queryOracle()');

        /*string memory apiCall = strConcat('json(https://api.kraken.com/0/public/OHLC).result.XETHZUSD[?(@[2]>',
            price,
            ')][0]');*/

        string memory apiCall = 'json(https://api.kraken.com/0/public/OHLC).result';

        string memory postData = strConcat('{ "pair": "ETHUSD", "interval": 1440, "since":',
            startdate,
            ' }');

        /*bytes32 apiCall = StringLib.uintToBytes(price);
        bytes32 postData = StringLib.uintToBytes(123);*/

        Info(apiCall);
        Info(postData);

        oraclize_query('URL', apiCall, postData );
    }

    // Callback to be called by once the oracle Query has been resolved
    function __callback(bytes32 myid, string result) public {
        Info(strConcat('Query result: ', result));
    }
}
