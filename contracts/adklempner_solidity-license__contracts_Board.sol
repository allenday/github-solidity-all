pragma solidity ^0.4.11;

import "./Licensed.sol";

contract Board {

  address public license;

  function Board(address _license) {
    license = _license;
  }

  event Post(address sender, string text);

  function post(string text) {
    require(Licensed(license).holdsValidLicense(msg.sender));
    Post(msg.sender, text);
  }

}
