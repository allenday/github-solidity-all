pragma solidity ^0.4.2;

import "./DataObject_v1.sol";
import "./DataObject_v2.sol";

contract BulkContract {
    DataObject_v1 public dataObject_v1;
    DataObject_v2 public dataObject_v2;

    function BulkContract(DataObject_v1 _dataObject_v1, DataObject_v2 _dataObject_v2) {
        dataObject_v1 = _dataObject_v1;
        dataObject_v2 = _dataObject_v2;
    }

    function getHashInDataObject(bytes32[] _ids) constant returns (bytes32[]) {
        bytes32[] memory hashes = new bytes32[](_ids.length);

        for (uint i; i<_ids.length; i++) {
            hashes[i] = dataObject_v1.getHash(_ids[i]);
        }
        return hashes;
    }

    function canReadInDataObject(address _account, bytes32[] _ids) constant returns (bool[]) {
        bool[] memory canReads = new bool[](_ids.length);
        for (uint i; i<_ids.length; i++) {
            canReads[i] = dataObject_v1.canRead(_account, _ids[i]);
        }
        return canReads;
    }

    function getExists(bytes32[] _ids) constant returns (bool[]) {
        bool[] memory exists = new bool[](_ids.length);
        for (uint i; i<_ids.length; i++) {
            exists[i] = dataObject_v1.exist(_ids[i]);
        }
        return exists;
    }

    function getWriteTimestamps(bytes32[] _ids) constant returns (uint[]) {
        uint[] memory writeTimestamps = new uint[](_ids.length);
        for (uint i; i<_ids.length; i++) {
            writeTimestamps[i] = dataObject_v2.getWriteTimestamp(_ids[i]);
        }
        return writeTimestamps;
    }
}