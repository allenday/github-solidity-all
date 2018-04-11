/*
 * Copyright 2016 Modum.io and the CSG Group at University of Zurich
 *
 * Licensed under the Apache License, Version 2.0 (the 'License'); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

contract TemperatureMeasurementB {

    address owner;
    address temperatureWriter;

    int8 minTemperature;
    int8 maxTemperature;
    
    uint32 firstFailedTimestampSeconds = 0;
    uint32 measurements = 0;
    uint32 failures = 0;

    /* Constructor, set who is allowed to write and the temperature range */
    function TemperatureMeasurementB(address _temperatureWriter,
            int8 _minTemperature, int8 _maxTemperature) {
        owner = msg.sender;
	    temperatureWriter = _temperatureWriter;
        minTemperature = _minTemperature;
        maxTemperature = _maxTemperature;
    }

    /* Any remaining funds should be sent back to the sender 
       Both, sender and the reporter can call this function */
    function done() {
        if (msg.sender == owner || msg.sender == temperatureWriter) {
            suicide(msg.sender);
        }
    }
  
    function reportTemperature(int8[] _temperatures, uint32[] _timestamps) public {
        /* Only temperature reporter can write temperature */
        if (msg.sender == temperatureWriter) {
            if(_temperatures.length != _timestamps.length) {
                throw;
            }
            /* read state variable, writing directly to it is expensive */
            var _measurements = measurements;
            var _failures = failures;
            var _maxTemperature = maxTemperature;
            var _minTemperature = minTemperature;
            var _firstFailedTimestampSeconds = firstFailedTimestampSeconds;
            for (uint32 i = 0; i < _temperatures.length; i++) {
		        _measurements++;
                if(_temperatures[i] > _maxTemperature 
                        || _temperatures[i] < _minTemperature) {
                    if(_firstFailedTimestampSeconds == 0) {
                        _firstFailedTimestampSeconds = _timestamps[i];
                        /* write state back, this is the expensive work */
                        firstFailedTimestampSeconds = _firstFailedTimestampSeconds;
                    }
                    _failures++;
                }
            }
            /* write state back, this is the expensive work */
            if(measurements != _measurements) {
        	    measurements = _measurements;
            }
	        if(failures != _failures) {
        	    failures = _failures;
            }
        }
    }

    /* Success is when no failed timestamp was reported and at least
       one measurement was carried out */
    function success() constant returns (bool res) {
       return firstFailedTimestampSeconds == 0 && measurements > 0;
    }
    
    /* Failed is when one failed timestamp was reported and at least
       one measurement was carried out */
    function failed() constant returns (bool res) {
       return firstFailedTimestampSeconds > 0 && measurements > 0;
    }
    
    /* The number of carried out measurements */
    function nrMeasurements() constant returns (uint32) {
       return measurements;
    }
    
    /* The number of reported failures */
    function nrFailures() constant returns (uint32) {
       return failures;
    }
    
    /* The first timestamp of the frist temperature that was out of range */
    function failedTimestampSeconds() constant returns (uint32) {
       return firstFailedTimestampSeconds;
    }
    
    /* The temperature range to check */
    function temperatureMin() constant returns (int8) {
       return minTemperature;
    }
    function temperatureMax() constant returns (int8) {
       return maxTemperature;
    }
}
