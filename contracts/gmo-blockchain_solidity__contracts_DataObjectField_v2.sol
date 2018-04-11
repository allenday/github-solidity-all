pragma solidity ^0.4.2;

import "./DataObject.sol";
import "./VersionField.sol";

contract DataObjectField_v2 is VersionField, DataObject {
    struct Field {
        bool isCreated; // independent field between versions
        uint tmpWriteTimestamp; // v2 original field
        uint writeTimestamp; // v2 original field
    }

    mapping (bytes32 => Field) public fields;

    function DataObjectField_v2(ContractNameService _cns) VersionField(_cns, CONTRACT_NAME) {}

    /** OVERRIDE */
    function setDefault(bytes32 _id) private {
        fields[_id] = Field({ isCreated: true, tmpWriteTimestamp: 0, writeTimestamp: 0 });
    }

    /** OVERRIDE */
    function existIdAtCurrentVersion(bytes32 _id) constant returns (bool) {
        return fields[_id].isCreated;
    }

    function setTmpWriteTimestamp(bytes32 _id, uint _tmpWriteTimestamp) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].tmpWriteTimestamp = _tmpWriteTimestamp;
    }

    function getTmpWriteTimestamp(bytes32 _id) constant returns (uint) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].tmpWriteTimestamp;
    }

    function setWriteTimestamp(bytes32 _id, uint _writeTimestamp) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].writeTimestamp = _writeTimestamp;
    }

    function getWriteTimestamp(bytes32 _id) constant returns (uint) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].writeTimestamp;
    }
}