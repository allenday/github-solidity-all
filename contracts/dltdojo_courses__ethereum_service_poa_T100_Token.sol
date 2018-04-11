pragma solidity ^0.4.14;
//
// metamask - rinkeby testnet - unlock
// Local Remix http://VMIP:8080/
// Contract - Environment - Injected Web3
// Settings - Solidity - 0.4.14
// FooToken - Create 
// https://rinkeby.etherscan.io/address/0xc7cd2ac531c8c2af17acaf34dff5c0fc0d777267
// FooToken - transfer - "0xF2aDf0e69cC645013585fBBca178de990BE40ED8", 1000000
// https://rinkeby.etherscan.io/tx/0xbe956d592f6c6ba294b9ab394522889c9417834de71664f45c9a35dc63682668
// 

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/StandardToken.sol";

contract FooToken is StandardToken {
  string public constant name = "FooToken";
  string public constant symbol = "FOT";
  uint256 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 2100 ether;

  function FooToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

// TODO 
// 1. Create YourToken
// rinkeby token contract url : https://rinkeby.etherscan.io/address/0xxxxxx
// 2. Transfer YourToken
// 3. YourToken - At Address
// 4. balanceOf - account[0]
//