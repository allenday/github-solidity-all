/*
This file is part of WeiFund.
*/

/*
The private service registry is used in WeiFund factory contracts to register
generated service contracts, such as our WeiFund standard campaign and enhanced
standard campaign contracts. It is usually only inherited by other contracts.
*/

pragma solidity ^0.4.16;


import "utils/IPrivateServiceRegistry.sol";


contract PrivateServiceRegistry is IPrivateServiceRegistry {
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

  function register(address _service)
    internal
    isNotRegisteredService(_service)
    returns (uint serviceId) {
    // create service ID by increasing services length
    serviceId = services.length++;

    // set the new service ID to the '_service' address
    services[serviceId] = _service;

    // set the ids store to link to the 'serviceId' created
    ids[_service] = serviceId;

    // fire the 'ServiceRegistered' event
    ServiceRegistered(msg.sender, _service);
  }

  function isService(address _service)
    public
    constant
    isRegisteredService(_service)
    returns (bool) {
    return true;
  }

  address[] public services;
  mapping(address => uint256) public ids;
}
