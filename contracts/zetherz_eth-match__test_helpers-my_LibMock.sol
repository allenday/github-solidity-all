pragma solidity ^0.4.15;

import '../../contracts/base/Lib.sol';

contract LibMock {

  function checkContract(address _addr) constant returns (bool) {
    return Lib.isContract(_addr);
  }

}
