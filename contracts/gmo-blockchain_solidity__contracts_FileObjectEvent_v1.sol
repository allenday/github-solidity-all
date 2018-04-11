pragma solidity ^0.4.2;

import "./FileObject.sol";
import "./VersionEvent.sol";

contract FileObjectEvent_v1 is VersionEvent, FileObject {
    event createEvent(address indexed _sender, bytes32 indexed _id);
    event setAllowCnsContractEvent(address indexed _sender, bytes32 indexed _id, address _cns, bytes32 _contractName, bool _isAdded);
    event setHashEvent(address indexed _sender, bytes32 indexed _id, address _writer, bytes32 _hash, uint _targetIdx);
    event setReaderIdEvent(address indexed _sender, bytes32 indexed _id, bytes32 _readerId);
    event setWriterIdEvent(address indexed _sender, bytes32 indexed _id, bytes32 _writerId);

    function FileObjectEvent_v1(ContractNameService _cns) VersionEvent(_cns, CONTRACT_NAME) {}

    function create(address _sender, bytes32 _id) onlyByVersionLogic {
        createEvent(_sender, _id);
    }

    function setAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) onlyByVersionLogic {
        setAllowCnsContractEvent(_sender, _id, _cns, _contractName, _isAdded);
    }

    function setHash(address _sender, bytes32 _id, address _writer, bytes32 _hash, uint _targetIdx) onlyByVersionLogic {
        setHashEvent(_sender, _id, _writer, _hash, _targetIdx);
    }

    function setReaderId(address _sender, bytes32 _id, bytes32 _readerId) onlyByVersionLogic {
        setReaderIdEvent(_sender, _id, _readerId);
    }

    function setWriterId(address _sender, bytes32 _id, bytes32 _writerId) onlyByVersionLogic {
        setWriterIdEvent(_sender, _id, _writerId);
    }
}