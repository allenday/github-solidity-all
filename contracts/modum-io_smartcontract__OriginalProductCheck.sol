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

contract OriginalProductCheck {

    address producer;
    address vendor;

    uint32 productionDateSecondes = 0;
    uint64 uniqueID = 0;
    uint32 sellingDateSeconds = 0;
    string sellingLocation;
    

    /* Constructor, set who is allowed to write  */
    function TemperatureMeasurementB(address _vendor,
            uint32 _productionDateSecondes, uint64 _uniqueID) {
        producer = msg.sender;
        productionDateSecondes = _productionDateSecondes;
        uniqueID = _uniqueID;
    }

    /* Any remaining funds should be sent back to the sender 
       Both, sender and the reporter can call this function */
    function done() {
        if (msg.sender == producer) {
            suicide(msg.sender);
        }
    }
  
    function productSold(uint64 _uniqueID, uint32 _sellingDateSeconds, string _sellingLocation) public {
        /* anyone can write, but only once */
        if (sellingDateSeconds == 0 && _uniqueID == uniqueID && _sellingDateSeconds > 0) {
            sellingDateSeconds = _sellingDateSeconds;
            sellingLocation = _sellingLocation;
        }
    }

    /* Sold is when a selling date is provided */
    function sold() constant returns (bool) {
       return sellingDateSeconds > 0;
    }
    
    function location() constant returns (string) {
       return sellingLocation;
    }
    
    function productID() constant returns (uint64) {
       return uniqueID;
    }
}
