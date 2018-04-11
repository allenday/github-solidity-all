pragma solidity ^0.4.16;

import "utils/IProxy.sol";


contract ProxyBased {
  modifier onlyProxy { require(msg.sender == address(proxy)); _; }

  function setProxy(address _proxy) internal {
    proxy = IProxy(_proxy);
  }

  IProxy public proxy;
}
