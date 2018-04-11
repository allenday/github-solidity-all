pragma solidity ^0.4.6;

import "./RentableProvider.sol";

contract Internet is RentableProvider {
  function Internet(string _name, string _description) RentableProvider("_name", "_description"){
    providerName = _name;
    description = _description;
  }
}