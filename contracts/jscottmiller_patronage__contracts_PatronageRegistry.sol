import {Patronage} from './Patronage.sol';

contract PatronageRegistry {
    address public registrar;
    address public shareholders;
    mapping (string => Patronage) patronageContractsByUsername;

    function PatronageRegistry(address _shareholders) {
        registrar = shareholders = msg.sender;
        if (_shareholders != address(0)) {
            shareholders = _shareholders;
        }
    }

    function registerUsername(string username, address payoutAddress) {
        if (msg.sender != registrar) {
            throw;
        }
        address existing = patronageContractsByUsername[username];
        if (existing != address(0)) {
            throw;
        }
        Patronage patronage = new Patronage(username, payoutAddress, shareholders);
        patronageContractsByUsername[username] = patronage;
    }

    function patronageContractForUsername(string username) returns (Patronage) {
        Patronage patronage = patronageContractsByUsername[username];
        if (patronage == address(0)) {
            throw;
        }
        return patronage;
    }

    function updateRegistrar(address newRegistrar) {
        if (registrar != msg.sender) {
            throw;
        }
        registrar = newRegistrar;
    }

    function () {
        throw;
    }
}
