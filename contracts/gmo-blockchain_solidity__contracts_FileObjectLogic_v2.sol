pragma solidity ^0.4.2;

import "./FileObjectLogic_v1.sol";
import "./FileObjectField_v2.sol";
import "./DataObject_v2.sol";

contract FileObjectLogic_v2 is FileObjectLogic_v1 {
    FileObjectField_v2 public field_v2;

    function FileObjectLogic_v2(ContractNameService _cns, FileObjectField_v1 _field_v1, FileObjectField_v2 _field_v2, FileObjectEvent_v1 _event_v1, DataObject_v2 _dataObject_v2, AddressGroup_v1 _addressGroup_v1) FileObjectLogic_v1(_cns, _field_v1, _event_v1, _dataObject_v2, _addressGroup_v1) {
        field_v2 = _field_v2;
    }

    function setFileObjectField_v2(FileObjectField_v2 _field) onlyByProvider {
        field_v2 = _field;
    }

    /** OVERRIDE */
    function create(address _sender, bytes32 _id, address _owner, bytes32 _nameHash, bytes32 _hash, address _cns, bytes32 _contractName) onlyByVersionContractOrLogic {
        super.create(_sender, _id, _owner, _nameHash, _hash, _cns, _contractName);
        field_v2.setTmpWriteTimestamp(_id, now);
    }

    /** OVERRIDE */
    function setHashByWriter(address _sender, bytes32 _id, address _writer, bytes32 _hash) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) onlyFromOwnerOrWriter(_writer, _id) {
        if (!isActive(_id)) throw;
        field_v2.setTmpWriteTimestamp(_id, now);
        setHash(_sender, _id, _writer, _hash, 2, 1);
    }

    /** OVERRIDE */
    function setHashByProvider(address _sender, bytes32 _id, bytes32 _hash) onlyByVersionContractOrLogic onlyFromProvider(_sender) {
        if (!isActive(_id)) throw;
        setHash(_sender, _id, _sender, _hash, 1, 2);
    }

    function getWriteTimestamp(bytes32 _id) constant returns (uint) {
        if (!isActive(_id)) return 0;
        return field_v2.getWriteTimestamp(_id);
    }

    function setHash(address _sender, bytes32 _id, address _writer, bytes32 _hash, uint _targetIdx, uint _compareIdx) private {
        field_v1.setHash(_id, _targetIdx, _hash);
        event_v1.setHash(_sender, _id, _writer, _hash, _targetIdx);

        if (_hash == field_v1.getHash(_id, _compareIdx) && _hash != field_v1.getHash(_id, 0)) {
            field_v1.setHash(_id, 0, _hash);
            field_v2.setWriteTimestamp(_id, field_v2.getTmpWriteTimestamp(_id));
            event_v1.setHash(_sender, _id, _writer, _hash, 0);
        }
    }
}