/*
The private service registry is used in WeiFund factory contracts to register
generated service contracts, such as our WeiFund standard campaign and enhanced
standard campaign contracts. It is usually only inherited by other contracts.
*/

pragma solidity ^0.4.16;


/// @title Private Service Registry - used to register generated service contracts.
/// @author Nick Dodson <nick.dodson@consensys.net>
contract IPrivateServiceRegistry {
  /// @notice register the service '_service' with the private service registry
  /// @param _service the service contract to be registered
  /// @return the service ID 'serviceId'
  function register(address _service) internal returns (uint256 serviceId) {}

  /// @notice is the service in question '_service' a registered service with this registry
  /// @param _service the service contract address
  /// @return either yes (true) the service is registered or no (false) the service is not
  function isService(address _service) public constant returns (bool) {}

  /// @notice helps to get service address
  /// @param _serviceId the service ID
  /// @return returns the service address of service ID
  function services(uint256 _serviceId) public constant returns (address _service) {}

  /// @notice returns the id of a service address, if any
  /// @param _service the service contract address
  /// @return the service id of a service
  function ids(address _service) public constant returns (uint256 serviceId) {}

  event ServiceRegistered(address _sender, address _service);
}
