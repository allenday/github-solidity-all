pragma solidity ^0.4.16;

import "utils/Proxy.sol";
import "utils/PrivateServiceRegistry.sol";
import "OwnedController.sol";


contract OwnedControllerFactory is PrivateServiceRegistry {
  function createProxy(address _owner) public returns (address) {
    Proxy proxy = new Proxy();
    proxy.transfer(new OwnedController(proxy, _owner));
    register(proxy);
    register(proxy.owner());
    return address(proxy);
  }

  function createController(address _proxy, address _owner) public returns (address service) {
    service = address(new OwnedController(_proxy, _owner));
    register(service);
  }
}
