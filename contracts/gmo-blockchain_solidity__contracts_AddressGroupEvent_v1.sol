pragma solidity ^0.4.2;

import "./AddressGroup.sol";
import "./VersionEvent.sol";

contract AddressGroupEvent_v1 is VersionEvent, AddressGroup {
    event createEvent(address indexed _sender, bytes32 indexed _id);
    event removeEvent(address indexed _sender, bytes32 indexed _id);
    event setAllowCnsContractEvent(address indexed _sender, bytes32 indexed _id, address _cns, bytes32 _contractName, bool _isAdded);
    event setOwnerEvent(address indexed _sender, bytes32 indexed _id, address _owner);
    event setMemberEvent(address indexed _sender, bytes32 indexed _id, address _member, bool _isAdded);
    event setChildEvent(address indexed _sender, bytes32 indexed _id, bytes32 _child, bool _isAdded);

    function AddressGroupEvent_v1(ContractNameService _cns) VersionEvent(_cns, CONTRACT_NAME) {}

    function create(address _sender, bytes32 _id) onlyByVersionLogic {
        createEvent(_sender, _id);
    }

    function remove(address _sender, bytes32 _id) onlyByVersionLogic {
        removeEvent(_sender, _id);
    }

    function setAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) onlyByVersionLogic {
        setAllowCnsContractEvent(_sender, _id, _cns, _contractName, _isAdded);
    }

    function setOwner(address _sender, bytes32 _id, address _owner) onlyByVersionLogic {
        setOwnerEvent(_sender, _id, _owner);
    }

    function setMember(address _sender, bytes32 _id, address _member, bool _isAdded) onlyByVersionLogic {
        setMemberEvent(_sender, _id, _member, _isAdded);
    }

    function setChild(address _sender, bytes32 _id, bytes32 _child, bool _isAdded) onlyByVersionLogic {
        setChildEvent(_sender, _id, _child, _isAdded);
    }
}