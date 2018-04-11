pragma solidity ^0.4.2;

import "./ContractNameService.sol";

contract CnsController {
    address public provider = msg.sender;
    ContractNameService public cns;
    bytes32 public contractName;

    modifier onlyByProvider() {
        if (msg.sender != provider) throw;
        _;
    }

    modifier onlyByVersionContract() {
        if (!isVersionContract()) throw;
        _;
    }

    modifier onlyByVersionLogic() {
        if (!isVersionLogic()) throw;
        _;
    }

    modifier onlyByVersionContractOrLogic() {
        if (!isVersionContractOrLogic()) throw;
        _;
    }

    function CnsController(ContractNameService _cns, bytes32 _contractName) {
        cns = _cns;
        contractName = _contractName;
    }

    function getCns() constant returns (ContractNameService) {
        return cns;
    }

    function getContractName() constant returns (bytes32) {
        return contractName;
    }

    function isVersionContract() constant returns (bool) {
        return cns.isVersionContract(msg.sender, contractName);
    }

    function isVersionLogic() constant returns (bool) {
        return cns.isVersionLogic(msg.sender, contractName);
    }

    function isVersionContractOrLogic() constant returns (bool) {
        return cns.isVersionContract(msg.sender, contractName) || cns.isVersionLogic(msg.sender, contractName);
    }
}