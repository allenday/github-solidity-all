//
// AIRA Builder for AirTrafficController contract
//
//

import 'creator/CreatorSatFix.sol';
import 'builder/Builder.sol';

/**
 * @title BuilderSatFix contract
 */
contract BuilderSatFix is Builder {
    /**
     * @dev Run script creation contract
     * @param _latitude is an latitude
     * @param _longitude is an longitude
     * @param _altitude is an altitude
     * @return address new contract
     */
    function create(int256 _latitude,
                    int256 _longitude,
                    int256 _altitude)
                    returns (address) {
        var inst = CreatorSatFix.create(_latitude, _longitude, _altitude);
        getContractsOf[msg.sender].push(inst);
        Builded(msg.sender, inst);
        return inst;
    }

    /**
     * @dev Run script creation contract
     * @param _latitude is an latitude
     * @param _longitude is an longitude
     * @return address new contract
     */
    function create(int256 _latitude,
                    int256 _longitude)
                    returns (address) {
        return create(_latitude, _longitude, 0);
    }
}
