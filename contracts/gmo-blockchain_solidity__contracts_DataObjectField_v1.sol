pragma solidity ^0.4.2;

import "./DataObject.sol";
import "./VersionField.sol";

contract DataObjectField_v1 is VersionField, DataObject {
    struct Field {
        bool isCreated; // independent field between versions
        address owner; // common field between versions
        bool isRemoved; // common field
        mapping (address => mapping (bytes32 => bool)) allowCnsContracts; // common field
        bytes32[3] hashes; // v1 original field
        bytes32 readerId; // v1 original field
        bytes32 writerId; // v1 original field
    }

    mapping (bytes32 => Field) public fields;

    function allowCnsContracts(bytes32 _id, address _cns, bytes32 _contractName) constant returns (bool) {
        return fields[_id].allowCnsContracts[_cns][_contractName];
    }

    function hashes(bytes32 _id) constant returns (bytes32[3]) {
        return fields[_id].hashes;
    }

    function DataObjectField_v1(ContractNameService _cns) VersionField(_cns, CONTRACT_NAME) {}

    /** OVERRIDE */
    function setDefault(bytes32 _id) private {
        bytes32[3] memory hashes;
        fields[_id] = Field({ isCreated: true, owner: 0, isRemoved: false, hashes: hashes, readerId: 0, writerId: 0 });
    }

    /** OVERRIDE */
    function existIdAtCurrentVersion(bytes32 _id) constant returns (bool) {
        return fields[_id].isCreated;
    }

    function create(bytes32 _id, address _owner, bytes32[3] _hashes, bytes32 _readerId, bytes32 _writerId) onlyByNextVersionOrVersionLogic {
        if (exist(_id)) throw;
        fields[_id] = Field({ isCreated: true, owner: _owner, isRemoved: false, hashes: _hashes, readerId: _readerId, writerId: _writerId });
    }

    function remove(bytes32 _id) onlyByNextVersionOrVersionLogic {
        if (!exist(_id)) throw;
        fields[_id].isRemoved = true;
    }

    function getIsRemoved(bytes32 _id) constant returns (bool) {
        if (shouldReturnDefault(_id)) return false;
        return fields[_id].isRemoved;
    }

    function setAllowCnsContract(bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].allowCnsContracts[_cns][_contractName] = _isAdded;
    }

    function isAllowCnsContract(address _cns, bytes32 _contractName, bytes32 _id) constant returns (bool) {
        if (shouldReturnDefault(_id)) return false;
        return fields[_id].allowCnsContracts[_cns][_contractName];
    }

    function setOwner(bytes32 _id, address _owner) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].owner = _owner;
    }

    function getOwner(bytes32 _id) constant returns (address) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].owner;
    }

    function setHash(bytes32 _id, uint _idx, bytes32 _hash) onlyByNextVersionOrVersionLogic {
        if (_idx > 2) throw;
        prepare(_id);
        fields[_id].hashes[_idx] = _hash;
    }

    function getHash(bytes32 _id, uint _idx) constant returns (bytes32) {
        if (_idx > 2) return 0;
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].hashes[_idx];
    }

    function setReaderId(bytes32 _id, bytes32 _readerId) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].readerId = _readerId;
    }

    function setWriterId(bytes32 _id, bytes32 _writerId) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].writerId = _writerId;
    }

    function getReaderId(bytes32 _id) constant returns (bytes32) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].readerId;
    }

    function getWriterId(bytes32 _id) constant returns (bytes32) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].writerId;
    }
}