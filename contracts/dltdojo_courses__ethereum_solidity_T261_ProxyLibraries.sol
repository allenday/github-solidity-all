pragma solidity ^0.4.14;

// The Parity Wallet Hack Explained – Zeppelin Solutions https://blog.zeppelin.solutions/on-the-parity-wallet-multisig-hack-405a8c12e8f7
// Proxy Libraries in Solidity – Zeppelin Solutions https://blog.zeppelin.solutions/proxy-libraries-in-solidity-79fbe4b970fd
// Integrate with consensys/live-libs · Issue #163 · ethereum/browser-solidity https://github.com/ethereum/browser-solidity/issues/163
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// remove internal  
contract SafeMathContract {
  function mul(uint256 a, uint256 b) constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract FooLib {
  // The directive using A for B; can be used to attach library functions (from the library A) to any type (B). 
  // These functions will receive the object they are called on as their first parameter (like the self variable in Python).

  using SafeMath for uint;

  function div(uint a, uint b) returns (uint){
      return a.div(b);
  }

}

contract FooContract {
  SafeMathContract safeMath;
  
  function FooContract(address safeMathAddress){
     safeMath = SafeMathContract(safeMathAddress);
  }

  function div(uint a, uint b) returns (uint){
     return safeMath.div(a,b);
  }
}