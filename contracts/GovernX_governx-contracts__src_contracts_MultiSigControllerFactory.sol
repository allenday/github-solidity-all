pragma solidity ^0.4.16;

import "utils/Proxy.sol";
import "utils/PrivateServiceRegistry.sol";
import "MultiSigController.sol";


contract MultiSigControllerFactory is PrivateServiceRegistry {
    function createProxy(address[] _members, uint256 _required) public returns (address) {
      Proxy proxy = new Proxy();
      proxy.transfer(new MultiSigController(proxy, _members, _required));
      register(proxy);
      return address(proxy);
    }

    function createController(address _proxy, address[] _members, uint256 _required) public returns (address service) {
      service = address(new MultiSigController(_proxy, _members, _required));
      register(service);
    }
}
