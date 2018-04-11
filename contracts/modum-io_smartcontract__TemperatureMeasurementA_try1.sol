

/*
 * Copyright 2016 Modum.io and the CSG Group at University of Zurich
 *
 * Licensed under the Apache License, Version 2.0 (the 'License'); you
may not
 * use this file except in compliance with the License. You may obtain a
copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and
limitations under
 * the License.
 */
pragma solidity ^0.4.3;

contract TemperatureMeasurementA {

    address owner;
    address temperatureWriter;
    string storageLocation;

    /* set at contract creation */
    int8 minTemperature;
    int8 maxTemperature;
    uint16 maxFailureReports;

    /* state */
    uint32[] failedTimestampSeconds;
	int8[] failedTemperatures;
    uint32 measurements = 0;
    uint32 failures = 0;
    uint32 firstTimestamp = 0;
    uint32 lastTimestamp = 0;
    bytes32[] hashes;

    /* Constructor, set who is allowed to write and the temperature range */
    function TemperatureMeasurementA(address _temperatureWriter,
            int8 _minTemperature, int8 _maxTemperature,
            uint16 _maxFailureReports, string _storageLocation) {
        owner = msg.sender;
	    temperatureWriter = _temperatureWriter;
		minTemperature = _minTemperature;
		maxTemperature = _maxTemperature;
        if(_maxFailureReports < 1) {
            throw;
        }
        maxFailureReports = _maxFailureReports;
        storageLocation = _storageLocation;
    }

    /* Any remaining funds should be sent back to the sender
       Both, sender and the reporter can call this function */
    function done() {
        if (msg.sender == owner || msg.sender == temperatureWriter) {
            suicide(msg.sender);
        }
    }

    function reportResult(uint32[] _failedTimestampSeconds, int8[] _failedTemperatures,
            uint32 _failures, uint32 _measurements, uint32 _firstTimestamp,
            uint32 _lastTimestamp, bytes32 _hash) public {

        /* Only temperature reporter can write temperature */

        if (msg.sender != temperatureWriter) {
            throw;
        }

        if(_failedTimestampSeconds.length != _failedTemperatures.length) {
            throw;
        }

        uint32 _current = uint32(failedTimestampSeconds.length);
        uint32 _len = uint32(_failedTimestampSeconds.length);
        uint16 _max = maxFailureReports;
        for (uint32 i = _current; (i - _current) < _len && i < _max; i++) {
            failedTimestampSeconds.push(_failedTimestampSeconds[(i-_current)]);
	        failedTemperatures.push(_failedTemperatures[(i-_current)]);
        }

        measurements += _measurements;
        failures += _failures;
        if (firstTimestamp == 0) {
            firstTimestamp = _firstTimestamp;
        }
        lastTimestamp = _lastTimestamp;
        hashes.push(_hash);
    }

    function generateReport2(int8[] _temperatures, uint32[] _timestamps) constant
            returns (uint32[], int8[], uint32, uint32, bytes32) {

        uint32 len = uint32 (_temperatures.length);

        if(len != _timestamps.length) {
            throw;
        }

        uint8[] memory b = new uint8[](5*len);
        uint32 _failures = 0;
        uint32[] memory _failedTimestampSeconds;
	    int8[] memory _failedTemperatures;

        for (uint16 i = 0; i < len; i++) {
            b[(i*5)+0]=uint8(_timestamps[i]);
            b[(i*5)+1]=uint8(shr(_timestamps[i], 8));
            b[(i*5)+2]=uint8(shr(_timestamps[i], 16));
            b[(i*5)+3]=uint8(shr(_timestamps[i], 24));
            b[(i*5)+4]=uint8(_temperatures[i]);

            if(_temperatures[i] > maxTemperature || _temperatures[i] < minTemperature) {
                _failures++;

            }
        }

        return (_failedTimestampSeconds, _failedTemperatures, _failures, len, sha256(b));
    }

    function generateReport(int8[] _temperatures, uint32[] _timestamps) constant
            returns (uint32[], int8[], uint32, uint32, bytes32) {

        var len = uint32 (_temperatures.length);

        if(len != _timestamps.length) {
            throw;
        }

        uint32 _failures = 0;
        uint32[] memory _failedTimestampSeconds;
	    int8[] memory _failedTemperatures;

        uint8[] memory b = new uint8[](5*len);
        for (uint16 i = 0; i < len; i++) {
            b[(i*5)+0]=uint8(_timestamps[i]);
            b[(i*5)+1]=uint8(shr(_timestamps[i], 8));
            b[(i*5)+2]=uint8(shr(_timestamps[i], 16));
            b[(i*5)+3]=uint8(shr(_timestamps[i], 24));
            b[(i*5)+4]=uint8(_temperatures[i]);

            if(_temperatures[i] > maxTemperature || _temperatures[i] < minTemperature) {
                _failures++;
                if(_failures < maxFailureReports) {
                    _failedTimestampSeconds[_failedTimestampSeconds.length] = (_timestamps[i]);
					_failedTemperatures[_failedTimestampSeconds.length] = (_temperatures[i]);
                }
            }
        }

        return (_failedTimestampSeconds, _failedTemperatures,
                _failures, len, sha256(b));
    }

    function verifyReport(uint16 series, int8[] _temperatures, uint32[] _timestamps)
            constant returns (bool) {
        var (_failedTimestampSeconds, _failedTemperatures, _failures, _measurements, _hash)
                = generateReport(_temperatures, _timestamps);
        if(series == hashes.length - 1) {
            /* full check */
            if(_failedTimestampSeconds.length != failedTimestampSeconds.length ||
                    _failedTemperatures.length != failedTemperatures.length ||
                    _failedTemperatures.length != _failedTimestampSeconds.length) {
                return false;
            }
            for (uint16 i = 0; i < failedTimestampSeconds.length; i++) {
                if(_failedTimestampSeconds[i] != failedTimestampSeconds[i]) {
                    return false;
                }
                if(_failedTemperatures[i] != failedTemperatures[i]) {
                    return false;
                }
            }

            return hashes[series] == _hash &&
                    _failures == failures &&
                    _measurements == measurements;
        } else {
            /* intermediate, check only hashes */
            return hashes[series] == _hash;
        }
    }

    /* Success is when no failed timestamp was reported and at least
       one measurement was carried out */
    function success() constant returns (bool) {
       return failedTimestampSeconds.length == 0 && measurements > 0;
    }

    /* Failed is when one failed timestamp was reported and at least
       one measurement was carried out */
    function failed() constant returns (bool) {
       return failedTimestampSeconds.length > 0 && measurements > 0;
    }

    /* The number of carried out measurements */
    function nrMeasurements() constant returns (uint32) {
       return measurements;
    }

    /* The number of reported failures */
    function nrFailures() constant returns (uint32) {
       return failures;
    }

    /* The timestamp of the frist temperature that was out of range */
    function failedTimestampSecondsAt(uint16 index) constant returns (uint32) {
       return failedTimestampSeconds[index];
    }

    /* The length of the failed timestamp array */
    function failedTimestampLength() constant returns (uint16) {
       return uint16(failedTimestampSeconds.length);
    }

	/* The temperature that was off at given indenx */
    function failedTemperaturesAt(uint16 index) constant returns (int8) {
       return failedTemperatures[index];
    }

    /* The length of the failed temperature array */
    function failedTemperaturesLength() constant returns (uint16) {
       return uint16(failedTemperatures.length);
    }

    /* The temperature range to check */
    function temperatureRange() constant returns (int8, int8) {
       return (minTemperature, maxTemperature);
    }

    /* The timestamp range */
    function timestampFirst() constant returns (uint32) {
       return firstTimestamp;
    }
    function timestampLast() constant returns (uint32) {
       return lastTimestamp;
    }

    /* Hash */
    function hashLength() constant returns (uint16) {
       return uint16(hashes.length);
    }
    function hashAt(uint16 index) constant returns (bytes32) {
       return hashes[index];
    }

    /* shift right, currently not implemented: https://github.com/ethereum/solidity/issues/33 */
    function shr(uint32 input, uint8 bits) constant returns (uint32) {
        return input / (2 ** uint32(bits));
    }
}

