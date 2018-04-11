pragma solidity ^0.4.15;
//
// https://ethereum.github.io/browser-solidity/
// https://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts/token
// 
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/PausableToken.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/TokenTimelock.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/VestedToken.sol";

contract FooStdToken is StandardToken {

  string public constant name = "FooToken";
  string public constant symbol = "FOO";
  uint256 public constant decimals = 3;

  uint256 public constant INITIAL_SUPPLY = 21000000;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
  function FooStdToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
