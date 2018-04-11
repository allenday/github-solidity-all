pragma solidity ^0.4.6;

import "./RentableProvider.sol";

contract Shelter is RentableProvider {

  function Shelter(string _name, string _description) RentableProvider("_name", "_description") {
    providerName = _name;
    description = _description;
  }

}