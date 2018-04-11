pragma solidity ^0.4.6;

import "./RentableProvider.sol";

contract Water is RentableProvider {
  function Water(string _name, string _description) RentableProvider("_name", "_description"){
    providerName = _name;
    description = _description;
  }
}