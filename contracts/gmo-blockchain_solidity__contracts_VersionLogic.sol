pragma solidity ^0.4.2;

import "./Utils.sol";
import "./CnsController.sol";

contract VersionLogic is CnsController, Utils {
    modifier onlyFromProvider(address _sender) {
        if (_sender != provider) throw;
        _;
    }

    function VersionLogic (ContractNameService _cns, bytes32 _contractName) CnsController(_cns, _contractName) {}
}
