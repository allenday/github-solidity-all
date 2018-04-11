pragma solidity ^0.4.2;

import "./Utils.sol";
import "./CnsController.sol";

contract VersionContract is CnsController, Utils {
    function VersionContract(ContractNameService _cns, bytes32 _contractName) CnsController(_cns, _contractName) {}

    function calcEnvHash(bytes32 _functionName) internal constant returns (bytes32) {
        bytes32 h = sha3(cns);
        h = sha3(h, contractName);
        h = sha3(h, _functionName);
        return h;
    }
}