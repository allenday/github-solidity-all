//
// AIRA Builder for AirTrafficController contract
//
//

import 'creator/CreatorAirTrafficController.sol';
import 'creator/CreatorAirTrafficControllerROS.sol';
import 'builder/Builder.sol';

/**
 * @title BuilderDroneEmployee contract
 */
contract BuilderAirTrafficController is Builder {
    /**
     * @dev Run script creation contract
     * @param _name is an ATC name
     * @param _area is an ATC area polygon
     * @param _market is a market for trading
     * @param _credits is a traded credits
     * @param _endpoint is a hardware ATC endpoint
     * @return address new contract
     */
    function create(string _name,
                    address[] _area,
                    Market _market,
                    Token _credits,
                    address _endpoint) returns (address) {
        var inst = CreatorAirTrafficController.create(_name, _area, _market, _credits);
        var ros  = CreatorAirTrafficControllerROS.create(inst, _endpoint);

        ros.delegate(inst);
        inst.setROSInterface(ros);
        inst.delegate(msg.sender);
 
        deal(inst);
        return inst;
    }
}
