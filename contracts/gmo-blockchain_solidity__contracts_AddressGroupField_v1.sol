pragma solidity ^0.4.2;

import "./AddressGroup.sol";
import "./VersionField.sol";

contract AddressGroupField_v1 is VersionField, AddressGroup {
    struct Field {
        bool isCreated; // independent field between versions
        address owner; // common field between versions
        bool isRemoved; // common field
        mapping (address => mapping (bytes32 => bool)) allowCnsContracts; // common field
        bytes32[] children; // v1 original field
        mapping (address => bool) members; // v1 original field
    }

    mapping (bytes32 => Field) public fields;

    function allowCnsContracts(bytes32 _id, address _cns, bytes32 _contractName) constant returns (bool) {
        return fields[_id].allowCnsContracts[_cns][_contractName];
    }

    function children(bytes32 _id) constant returns (bytes32[]) {
        return fields[_id].children;
    }

    function members(bytes32 _id, address _member) constant returns (bool) {
        return fields[_id].members[_member];
    }

    function AddressGroupField_v1(ContractNameService _cns) VersionField(_cns, CONTRACT_NAME) {}

    /** OVERRIDE */
    function setDefault(bytes32 _id) private {
        bytes32[] memory emptyArray;
        fields[_id] = Field({ isCreated: true, owner: 0, isRemoved: false, children: emptyArray });
    }

    /** OVERRIDE */
    function existIdAtCurrentVersion(bytes32 _id) constant returns (bool) {
        return fields[_id].isCreated;
    }

    function create(bytes32 _id, address _owner, bytes32[] _children) onlyByNextVersionOrVersionLogic {
        if (exist(_id)) throw;
        fields[_id] = Field({ isCreated: true, owner: _owner, isRemoved: false, children: _children });
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

    function setMember(bytes32 _id, address _member, bool _isAdded) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].members[_member] = _isAdded;
    }

    function isMember(address _account, bytes32 _id) constant returns (bool) {
        if (shouldReturnDefault(_id)) return false;
        return fields[_id].members[_account];
    }

    function addChild(bytes32 _id, bytes32 _child) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        for (uint i = 0; i < fields[_id].children.length; i++) {
            if (fields[_id].children[i] == _child) return;
        }
        fields[_id].children.push(_child);
    }

    function removeChild(bytes32 _id, bytes32 _child) onlyByNextVersionOrVersionLogic {
        prepare(_id);
        for (uint i = 0; i < fields[_id].children.length; i++) {
            if (fields[_id].children[i] == _child) {
                fields[_id].children[i] = fields[_id].children[fields[_id].children.length - 1];
                fields[_id].children.length--;
                return;
            }
        }
    }

    function getChild(bytes32 _id, uint _idx) constant returns (bytes32) {
        if (shouldReturnDefault(_id)) return 0;
        if (fields[_id].children.length <= _idx) return 0;
        return fields[_id].children[_idx];
    }

    function getChildrenLength(bytes32 _id) constant returns (uint) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].children.length;
    }
}