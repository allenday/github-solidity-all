pragma solidity ^0.4.13;

import './strings.sol';
import './OpenFund.sol';

contract OpenFundFactory is usingOraclize {
  using strings for *;
  int huh = 24;

  address public _owner;
  mapping (bytes32 => mapping(string => address)) _repositories;

  function OpenFundFactory() {
  }

  function addRepo(bytes32 user, string repo) {
    address openfund = new OpenFund(user, repo);
    _repositories[user][repo] = openfund;
  }

  function getRepo(bytes32 user, string repo) constant returns (address) {
    return _repositories[user][repo];
  }
}