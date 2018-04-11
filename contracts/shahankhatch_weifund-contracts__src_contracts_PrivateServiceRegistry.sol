pragma solidity ^0.4.3;


contract PrivateServiceRegistry {

  modifier isRegisteredService(address _service) {
    // does the service exist in the registry, is the service address not empty
    if (services.length > 0) {
      if (services[ids[_service]] == _service && _service != address(0)) {
        _;
      }
    }
  }

  modifier isNotRegisteredService(address _service) {
    // if the service '_service' is not a registered service
    if (!isService(_service)) {
      _;
    }
  }

  /// @notice register the service '_service' with the private service registry
  /// @param _service the service contract to be registered
  /// @return the service ID 'serviceId'
  function register(address _service) isNotRegisteredService(_service) internal returns (uint serviceId) {
    // create service ID by increasing services length
    serviceId = services.length++;

    // set the new service ID to the '_service' address
    services[serviceId] = _service;

    // set the ids store to link to the 'serviceId' created
    ids[_service] = serviceId;

    // fire the 'ServiceRegistered' event
    ServiceRegistered(_service);
  }

  /// @notice is the service in question '_service' a registered service with this registry
  /// @param _service the service contract address
  /// @return either yes (true) the service is registered or no (false) the service is not
  function isService(address _service) isRegisteredService(_service) constant public returns (bool) {
    return true;
  }

  address[] public services;
  mapping(address => uint) public ids;

  event ServiceRegistered(address _service);
}
