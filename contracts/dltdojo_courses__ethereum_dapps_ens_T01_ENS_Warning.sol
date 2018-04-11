pragma solidity ^0.4.15;
//
// https://ethereum.github.io/browser-solidity/
// https://github.com/ethereum/ens/blob/master/contracts/ENS.sol
//
import "github.com/ethereum/ens/contracts/ENS.sol";

// github.com/ethereum/ens/contracts/ENS.sol:19:48: Warning: "throw" is deprecated in favour of "revert()", "require()" and "assert()".
//        if (records[node].owner != msg.sender) throw;