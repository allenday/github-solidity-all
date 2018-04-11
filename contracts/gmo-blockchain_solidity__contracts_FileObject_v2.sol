pragma solidity ^0.4.2;

import "./FileObject.sol";
import "./FileObject_v1.sol";
import "./FileObjectLogic_v2.sol";
import "./VersionContract.sol";

contract FileObject_v2 is FileObject_v1 {
    FileObjectLogic_v2 public logic_v2;

    function FileObject_v2(ContractNameService _cns, FileObjectLogic_v1 _logic_v1, FileObjectLogic_v2 _logic_v2) FileObject_v1(_cns, _logic_v1) {
        logic_v2 = _logic_v2;
    }

    function setFileObjectLogic_v2(FileObjectLogic_v2 _logic) onlyByProvider {
        logic_v2 = _logic;
    }

    /** OVERRIDE */
    function create(bytes32 _id, address _owner, bytes32 _nameHash, bytes32 _hash, address _cns, bytes32 _contractName) {
        logic_v2.create(msg.sender, _id, _owner, _nameHash, _hash, _cns, _contractName);
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