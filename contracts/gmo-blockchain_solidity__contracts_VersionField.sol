pragma solidity ^0.4.2;

import "./CnsController.sol";

contract VersionField is CnsController {
    VersionField public prevVersion;
    VersionField public nextVersion;

    modifier onlyByNextVersionOrVersionLogic() {
        if (!isVersionLogic() && msg.sender != address(nextVersion)) throw;
        _;
    }

    function VersionField(ContractNameService _cns, bytes32 _contractName) CnsController(_cns, _contractName) {}

    function setPrevVersion(VersionField _prevVersion) onlyByProvider {
        prevVersion = _prevVersion;
    }

    function setNextVersion(VersionField _nextVersions) onlyByProvider {
        nextVersion = _nextVersions;
    }

    function exist(bytes32 _id) constant returns (bool) {
        return existIdBeforeVersion(_id) || existIdAtCurrentVersion(_id) || existIdAfterVersion(_id);
    }

    function existIdAfterVersion(bytes32 _id) constant returns (bool) {
        if (address(nextVersion) == 0) return false;
        if (nextVersion.existIdAtCurrentVersion(_id)) return true;
        return nextVersion.existIdAfterVersion(_id);
    }

    function existIdBeforeVersion(bytes32 _id) constant returns (bool) {
        if (address(prevVersion) == 0) return false;
        if (prevVersion.existIdAtCurrentVersion(_id)) return true;
        return prevVersion.existIdBeforeVersion(_id);
    }

    function prepare(bytes32 _id) internal {
        if (!exist(_id)) throw;
        if (!existIdAtCurrentVersion(_id)) setDefault(_id);
    }

    function shouldReturnDefault(bytes32 _id) internal constant returns (bool) {
        return exist(_id) && !existIdAtCurrentVersion(_id);
    }

    function setDefault(bytes32 _id) private;
    function existIdAtCurrentVersion(bytes32 _id) constant returns (bool);
}