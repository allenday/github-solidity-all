pragma solidity ^0.4.15;

/**
 * @title Lib
 * @dev Lib of common funcs
 */
library Lib {
  // whether given address is a contract or not based on bytecode
  function isContract(address addr) internal constant returns (bool) {
    uint size;
    assembly {
      size := extcodesize(addr)
    }
    return (size > 1); // testing returned size "1" for non-contract accounts, so we're using that.
  }
}
