pragma solidity ^0.4.2;

import "./DataObject.sol";
import "./DataObject_v1.sol";
import "./DataObjectLogic_v2.sol";
import "./VersionContract.sol";

contract DataObject_v2 is DataObject_v1 {
    DataObjectLogic_v2 public logic_v2;

    function DataObject_v2(ContractNameService _cns, DataObjectLogic_v1 _logic_v1, DataObjectLogic_v2 _logic_v2) DataObject_v1(_cns, _logic_v1) {
        logic_v2 = _logic_v2;
    }

    function setDataObjectLogic_v2(DataObjectLogic_v2 _logic) onlyByProvider {
        logic_v2 = _logic;
    }

    /** OVERRIDE */
    function create(bytes32 _id, address _owner, bytes32 _hash, address _cns, bytes32 _contractName) {
        logic_v2.create(msg.sender, _id, _owner, _hash, _cns, _contractName);
    }

    /** OVERRIDE */
    function setHashByWriter(bytes32 _id, address _writer, bytes32 _hash) {
        logic_v2.setHashByWriter(msg.sender, _id, _writer, _hash);
    }

    /** OVERRIDE */
    function setHashByProvider(bytes32 _id, bytes32 _hash) {
        logic_v2.setHashByProvider(msg.sender, _id, _hash);
    }

    function getWriteTimestamp(bytes32 _id) constant returns (uint) {
        return logic_v2.getWriteTimestamp(_id);
    }
}