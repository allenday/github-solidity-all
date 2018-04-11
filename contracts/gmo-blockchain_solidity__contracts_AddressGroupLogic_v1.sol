pragma solidity ^0.4.2;

import "./AddressGroup.sol";
import "./AddressGroupEvent_v1.sol";
import "./AddressGroupField_v1.sol";
import "./VersionLogic.sol";

contract AddressGroupLogic_v1 is VersionLogic, AddressGroup {
    AddressGroupField_v1 public field_v1;
    AddressGroupEvent_v1 public event_v1;

    modifier onlyFromAllowCnsContractLogic(address _sender, bytes32 _id) {
        VersionLogic logic = VersionLogic(_sender);
        if (!(isAllowCnsContract(logic.getCns(), logic.getContractName(), _id) || logic.getCns().isVersionLogic(_sender, logic.getContractName()))) throw;
        _;
    }

    function AddressGroupLogic_v1(ContractNameService _cns, AddressGroupField_v1 _field, AddressGroupEvent_v1 _event) VersionLogic(_cns, CONTRACT_NAME) {
        field_v1 = _field;
        event_v1 = _event;
    }

    function setAddressGroupField_v1(AddressGroupField_v1 _field) onlyByProvider {
        field_v1 = _field;
    }

    function setAddressGroupEvent_v1(AddressGroupEvent_v1 _event) onlyByProvider {
        event_v1 = _event;
    }

    function create(address _sender, bytes32 _id, address _owner, address[] _members, address _cns, bytes32 _contractName) onlyByVersionContractOrLogic {
        bytes32[] memory emptyChildren;
        field_v1.create(_id, _owner, emptyChildren);
        event_v1.create(_sender, _id);
        event_v1.setOwner(_sender, _id, _owner);

        field_v1.setAllowCnsContract(_id, _cns, _contractName, true);
        event_v1.setAllowCnsContract(_sender, _id, _cns, _contractName, true);

        for (uint i = 0; i < _members.length; i++) {
            field_v1.setMember(_id, _members[i], true);
            event_v1.setMember(_sender, _id, _members[i], true);
        }
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

    function addMembers(address _sender, bytes32 _id, address[] _members) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        for (uint i = 0; i < _members.length; i++) {
            field_v1.setMember(_id, _members[i], true);
            event_v1.setMember(_sender, _id, _members[i], true);
        }
    }

    function removeMembers(address _sender, bytes32 _id, address[] _members) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        for (uint i = 0; i < _members.length; i++) {
            field_v1.setMember(_id, _members[i], false);
            event_v1.setMember(_sender, _id, _members[i], false);
        }
    }

    function isMember(address _account, bytes32 _id) constant returns (bool) {
        if (!isActive(_id)) return false;
        return isMemberInDescendant(_account, _id);
    }

    function addChild(address _sender, bytes32 _id, bytes32 _child) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        field_v1.addChild(_id, _child);
        event_v1.setChild(_sender, _id, _child, true);
    }

    function removeChild(address _sender, bytes32 _id, bytes32 _child) onlyByVersionContractOrLogic onlyFromAllowCnsContractLogic(_sender, _id) {
        if (!isActive(_id)) throw;
        field_v1.removeChild(_id, _child);
        event_v1.setChild(_sender, _id, _child, false);
    }

    function getChild(bytes32 _id, uint _idx) constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getChild(_id, _idx);
    }

    function getChildrenLength(bytes32 _id) constant returns (uint) {
        if (!isActive(_id)) return 0;
        return field_v1.getChildrenLength(_id);
    }

    function setAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) private {
        field_v1.setAllowCnsContract(_id, _cns, _contractName, _isAdded);
        event_v1.setAllowCnsContract(_sender, _id, _cns, _contractName, _isAdded);
    }

    function isMemberInDescendant(address _account, bytes32 _id) private constant returns (bool) {
        if (!isActive(_id)) return false;
        if (field_v1.isMember(_account, _id)) return true;
        for (uint i = 0; i < field_v1.getChildrenLength(_id); i++) {
            if (isMemberInDescendant(_account, field_v1.getChild(_id, i))) return true;
        }
        return false;
    }
}
