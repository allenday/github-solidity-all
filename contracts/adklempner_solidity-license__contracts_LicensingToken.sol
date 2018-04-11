pragma solidity ^0.4.11;


import "./zeppelin/token/StandardToken.sol";


contract LicensingToken is StandardToken {

  string public name = "LicensingToken";
  string public symbol = "LIT";

  function LicensingToken() {

  }

  function getTokens() {
    balances[msg.sender] = balances[msg.sender].add(100);
  }

}
