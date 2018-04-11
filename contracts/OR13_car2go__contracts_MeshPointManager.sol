pragma solidity ^0.4.8;
import "./MeshPoint.sol";
import "./IndexedEnumerableSetLib.sol";
import './zeppelin/lifecycle/Killable.sol';
import './Transmute/EventStore.sol';

contract MeshPointManager is EventStore {
  using IndexedEnumerableSetLib for IndexedEnumerableSetLib.IndexedEnumerableSet;

  mapping (address => address) creatorMeshPointMapping;
  mapping (string => address) nameMeshPointMapping;
  IndexedEnumerableSetLib.IndexedEnumerableSet meshPointAddresses;

  // Events
  event AccessRequested(address indexed requestorAddress);
  event AuthorizationGranted(address indexed requestorAddress);
  event AuthorizationRevoked(address indexed requestorAddress);
  event MeshPointCreated(address _address, address _creatorAddress, string _name, uint _timeCreated);
  event MeshPointDestroyed(address _address);

  // Fallback Function
  function() payable {}

  // Constructor
  function MeshPointManager() payable {
  }

  // Modifiers
  modifier checkExistence(address _meshPointAddress) {
    if (!meshPointAddresses.contains(_meshPointAddress))
      throw;
    _;
  }

  // Helper Functions
  function getMeshPointByCreator() constant returns (address)  {
    return creatorMeshPointMapping[msg.sender];
  }

  function getMeshPointByName(string _name) constant returns (address)  {
    return nameMeshPointMapping[_name];
  }

  function getFaucets() constant returns (address[])  {
    return meshPointAddresses.values;
  }

  // Interface
	function createMeshPoint(string _name) payable returns (address) {
    // Validate Local State
    if (nameMeshPointMapping[_name] != 0) {
      throw;
    }
    if (creatorMeshPointMapping[msg.sender] != 0) {
      throw;
    }

    // Update Local State

    // Interact With Other Contracts
		MeshPoint _newMeshPoint = new MeshPoint(_name, msg.sender);
    if (!_newMeshPoint.send(msg.value)) {
      throw;
    }

    // Update State Dependent On Other Contracts
    meshPointAddresses.add(address(_newMeshPoint));
    creatorMeshPointMapping[msg.sender] = address(_newMeshPoint);
    nameMeshPointMapping[_name] = address(_newMeshPoint);

    // Emit Events
    MeshPointCreated(address(_newMeshPoint), msg.sender, _name, _newMeshPoint.timeCreated());
    return address(_newMeshPoint);
	}

  function requestAccess(address _meshPointAddress, address _requestorAddress ) checkExistence(_meshPointAddress) {
    MeshPoint _meshPoint = MeshPoint(_meshPointAddress);
    _meshPoint.addRequestorAddress(_requestorAddress);
    AccessRequested(_requestorAddress);
  }

  function authorizeAccess(address _meshPointAddress, address _requestorAddress ) checkExistence(_meshPointAddress) {
    MeshPoint _meshPoint = MeshPoint(_meshPointAddress);
    _meshPoint.authorizeRequestorAddress(_requestorAddress);
    AuthorizationGranted(_requestorAddress);
  }

  function revokeAccess(address _meshPointAddress, address _requestorAddress) checkExistence(_meshPointAddress) {
    MeshPoint _meshPoint = MeshPoint(_meshPointAddress);
    _meshPoint.revokeRequestorAddress(_requestorAddress);
    AuthorizationRevoked(_requestorAddress);
  }

  function killMeshPoint(address _address, string _name, address _creator)  {
    // Validate Local State
    if (nameMeshPointMapping[_name] == 0) {
      throw;
    }
    if ((_creator != msg.sender && this.owner() != msg.sender) || creatorMeshPointMapping[_creator] == 0) {
      throw;
    }

    // Update Local State
    delete nameMeshPointMapping[_name];
    delete creatorMeshPointMapping[_creator];
    meshPointAddresses.remove(_address);

    // Interact With Other Contracts
    MeshPoint _meshPoint = MeshPoint(_address);
    _meshPoint.kill();

    // Emit Events
    MeshPointDestroyed(_address);
  }
}
