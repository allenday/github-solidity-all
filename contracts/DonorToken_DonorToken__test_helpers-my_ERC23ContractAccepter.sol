pragma solidity ^0.4.13;


import '../../contracts/base/ERC23Contract.sol';


contract ERC23ContractAccepter is ERC23Contract {

  function tokenFallback(address /*_from*/, uint256 /*_value*/, bytes /*_data*/) external {
    // don't throw, aka accept
  }

}
