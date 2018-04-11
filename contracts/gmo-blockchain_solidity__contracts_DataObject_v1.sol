pragma solidity ^0.4.2;

import "./DataObject.sol";
import "./DataObjectLogic_v1.sol";
import "./VersionContract.sol";

contract DataObject_v1 is VersionContract, DataObject {
    DataObjectLogic_v1 public logic_v1;

    function DataObject_v1(ContractNameService _cns, DataObjectLogic_v1 _logic) VersionContract(_cns, CONTRACT_NAME) {
        logic_v1 = _logic;
    }

    function setDataObjectLogic_v1(DataObjectLogic_v1 _logic) onlyByProvider {
        logic_v1 = _logic;
    }

    function create(bytes32 _id, address _owner, bytes32 _hash, address _cns, bytes32 _contractName) {
        logic_v1.create(msg.sender, _id, _owner, _hash, _cns, _contractName);
    }

    function remove(bytes32 _id) {
        logic_v1.remove(msg.sender, _id);
    }

    function exist(bytes32 _id) constant returns (bool) {
        return logic_v1.exist(_id);
    }

    function isActive(bytes32 _id) constant returns (bool) {
        return logic_v1.isActive(_id);
    }

    function addAllowCnsContract(bytes32 _id, address _cns, bytes32 _contractName) {
        logic_v1.addAllowCnsContract(msg.sender, _id, _cns, _contractName);
    }

    function removeAllowCnsContract(bytes32 _id, address _cns, bytes32 _contractName) {
        logic_v1.removeAllowCnsContract(msg.sender, _id, _cns, _contractName);
    }

    function isAllowCnsContract(address _cns, bytes32 _contractName, bytes32 _id) constant returns (bool) {
        return logic_v1.isAllowCnsContract(_cns, _contractName, _id);
    }

    function setOwner(bytes32 _id, address _new) {
        logic_v1.setOwner(msg.sender, _id, _new);
    }

    function getOwner(bytes32 _id) constant returns (address) {
        return logic_v1.getOwner(_id);
    }

    function setHashByWriter(bytes32 _id, address _writer, bytes32 _hash) {
        logic_v1.setHashByWriter(msg.sender, _id, _writer, _hash);
    }

    function setHashByProvider(bytes32 _id, bytes32 _hash) {
        logic_v1.setHashByProvider(msg.sender, _id, _hash);
    }

    function getHash(bytes32 _id) constant returns (bytes32) {
        return logic_v1.getHash(_id);
    }

    function setReaderId(bytes32 _id, bytes32 _readerId) {
        logic_v1.setReaderId(msg.sender, _id, _readerId);
    }

    function setWriterId(bytes32 _id, bytes32 _writerId) {
        logic_v1.setWriterId(msg.sender, _id, _writerId);
    }

    function getReaderId(bytes32 _id) constant returns (bytes32) {
        return logic_v1.getReaderId(_id);
    }

    function getWriterId(bytes32 _id) constant returns (bytes32) {
        return logic_v1.getWriterId(_id);
    }

    function canRead(address _account, bytes32 _id) constant returns (bool) {
        return logic_v1.canRead(_account, _id);
    }

    function canWrite(address _account, bytes32 _id) constant returns (bool) {
        return logic_v1.canWrite(_account, _id);
    }
}