pragma solidity ^0.4.16;

import "utils/Proxy.sol";
import "utils/PrivateServiceRegistry.sol";
import "OpenController.sol";


contract OpenControllerFactory is PrivateServiceRegistry {
  function createProxy() public returns (address) {
    Proxy proxy = new Proxy();
    OpenController controller = new OpenController(proxy);
    proxy.transfer(address(controller));
    register(proxy);
    return address(proxy);
  }

  function createController(address _proxy) public returns (address service) {
    service = address(new OpenController(_proxy));
    register(service);
  }
}
