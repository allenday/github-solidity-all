pragma solidity ^0.4.2;

import "./VersionLogic.sol";
import "./DataObject.sol";
import "./DataObjectField_v1.sol";
import "./DataObjectEvent_v1.sol";
import "./AddressGroup_v1.sol";

contract DataObjectLogic_v1 is VersionLogic, DataObject {
    DataObjectField_v1 public field_v1;
    DataObjectEvent_v1 public event_v1;
    AddressGroup_v1 public addressGroup_v1;

    modifier onlyFromAllowCnsContractLogic(address _sender, bytes32 _id) {
        VersionLogic logic = VersionLogic(_sender);
        if (!(isAllowCnsContract(logic.getCns(), logic.getContractName(), _id) || logic.getCns().isVersionLogic(_sender, logic.getContractName()))) throw;
        _;
    }

    modifier onlyFromOwnerOrWriter(address _sender, bytes32 _id) {
        if (!canWrite(_sender, _id)) throw;
        _;
    }

    function DataObjectLogic_v1(ContractNameService _cns, DataObjectField_v1 _field, DataObjectEvent_v1 _event, AddressGroup_v1 _addressGroup) VersionLogic(_cns, CONTRACT_NAME) {
        field_v1 = _field;
        event_v1 = _event;
        addressGroup_v1 = _addressGroup;
    }

    function setDataObjectField_v1(DataObjectField_v1 _field) onlyByProvider {
        field_v1 = _field;
    }

    function setDataObjectEvent_v1(DataObjectEvent_v1 _event) onlyByProvider {
        event_v1 = _event;
    }

    function setAddressGroup_v1(AddressGroup_v1 _addressGroup) onlyByProvider {
        addressGroup_v1 = _addressGroup;
    }

    function create(address _sender, bytes32 _id, address _owner, bytes32 _hash, address _cns, bytes32 _contractName) onlyByVersionContractOrLogic {
        var (readerId, writerId) = createReaderWriter(_id, _owner, _cns, _contractName);
        bytes32[3] memory hashes;
        hashes[2] = _hash;
        field_v1.create(_id, _owner, hashes, readerId, writerId);
        event_v1.create(_sender, _id);
        event_v1.setOwner(_sender, _id, _owner);
        event_v1.setHash(_sender, _id, _owner, _hash, 2);
        event_v1.setReaderId(_sender, _id, readerId);
        event_v1.setWriterId(_sender, _id, writerId);

        field_v1.setAllowCnsContract(_id, _cns, _contractName, true);
        event_v1.setAllowCnsContract(_sender, _id, _cns, _contractName, true);
    }

    function remove(address _sender, bytes32 _id) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        field_v1.remove(_id);
        event_v1.remove(_sender, _id);
    }

    function exist(bytes32 _id) constant returns (bool) {
        return field_v1.exist(_id);
    }

    function isActive(bytes32 _id) constant returns (bool) {
        return exist(_id) && !field_v1.getIsRemoved(_id);
    }

    function addAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        setAllowCnsContract(_sender, _id, _cns, _contractName, true);
    }

    function removeAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        setAllowCnsContract(_sender, _id, _cns, _contractName, false);
    }

    function isAllowCnsContract(address _cns, bytes32 _contractName, bytes32 _id) constant returns (bool) {
        if (!isActive(_id)) return false;
        return field_v1.isAllowCnsContract(_cns, _contractName, _id);
    }

    function setOwner(address _sender, bytes32 _id, address _owner) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        field_v1.setOwner(_id, _owner);
        event_v1.setOwner(_sender, _id, _owner);
    }

    function getOwner(bytes32 _id) constant returns (address) {
        if (!isActive(_id)) return 0;
        return field_v1.getOwner(_id);
    }

    function setHashByWriter(address _sender, bytes32 _id, address _writer, bytes32 _hash) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) onlyFromOwnerOrWriter(_writer, _id) {
        if (!isActive(_id)) throw;
        setHash(_sender, _id, _writer, _hash, 2, 1);
    }

    function setHashByProvider(address _sender, bytes32 _id, bytes32 _hash) onlyByVersionContractOrLogic onlyFromProvider(_sender) {
        if (!isActive(_id)) throw;
        setHash(_sender, _id, _sender, _hash, 1, 2);
    }

    function getHash(bytes32 _id) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getHash(_id, 0);
    }

    function setReaderId(address _sender, bytes32 _id, bytes32 _readerId) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        field_v1.setReaderId(_id, _readerId);
        event_v1.setReaderId(_sender, _id, _readerId);
    }

    function setWriterId(address _sender, bytes32 _id, bytes32 _writerId) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        field_v1.setWriterId(_id, _writerId);
        event_v1.setWriterId(_sender, _id, _writerId);
    }

    function getReaderId(bytes32 _id) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getReaderId(_id);
    }

    function getWriterId(bytes32 _id) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getWriterId(_id);
    }

    function canRead(address _account, bytes32 _id) constant returns (bool) {
        if (!isActive(_id)) return false;
        if (getOwner(_id) == _account) return true;
        return addressGroup_v1.isMember(_account, field_v1.getReaderId(_id));
    }

    function canWrite(address _account, bytes32 _id) constant returns (bool) {
        if (!isActive(_id)) return false;
        if (getOwner(_id) == _account) return true;
        return addressGroup_v1.isMember(_account, field_v1.getWriterId(_id));
    }

    function createReaderWriter(bytes32 _id, address _owner, address _cns, bytes32 _contractName) private returns (bytes32 _readerId, bytes32 _writerId) {
        bytes32 tmpId = transferUniqueId(_id);
        while(true) {
            if (!addressGroup_v1.exist(tmpId)) {
                if (_readerId == 0) {
                    _readerId = tmpId;
                } else if (_writerId == 0) {
                    _writerId = tmpId;
                    break;
                }
            }
            tmpId = transferUniqueId(tmpId);
        }
        address[] memory emptyAddresses;
        addressGroup_v1.create(_readerId, _owner, emptyAddresses, _cns, _contractName);
        addressGroup_v1.create(_writerId, _owner, emptyAddresses, _cns, _contractName);
    }

    function setAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) private {
        field_v1.setAllowCnsContract(_id, _cns, _contractName, _isAdded);
        event_v1.setAllowCnsContract(_sender, _id, _cns, _contractName, _isAdded);
    }

    function setHash(address _sender, bytes32 _id, address _writer, bytes32 _hash, uint _targetIdx, uint _compareIdx) private {
        field_v1.setHash(_id, _targetIdx, _hash);
        event_v1.setHash(_sender, _id, _writer, _hash, _targetIdx);

        if (_hash == field_v1.getHash(_id, _compareIdx)) {
            field_v1.setHash(_id, 0, _hash);
            event_v1.setHash(_sender, _id, _writer, _hash, 0);
        }
    }
}