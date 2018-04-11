pragma solidity ^0.4.2;

import "./CnsController.sol";

contract VersionEvent is CnsController {
    function VersionEvent (ContractNameService _cns, bytes32 _contractName) CnsController(_cns, _contractName) {}
}