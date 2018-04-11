pragma solidity ^0.4.14;
//
// Edge computing - Wikipedia  https://en.wikipedia.org/wiki/Edge_computing
// The Cloud Computing Era Could Be Nearing Its End | WIRED 
// https://www.wired.com/story/its-time-to-think-beyond-cloud-computing
//
// one token to rule them all

contract CloudComputing {
    TheOneToken token;
    function doWorkAndPayTOT() {}
}

contract EdgeAliceComputing {
    EdgeAliceToken token;
    CloudComputing computing;
    function doWorkAndPayEAT() {}
}

contract EdgeBobComputing {
    EdgeBobToken token;
    EdgeAliceComputing computing;
    function doWorkAndPayEBT() {}
}

contract UserFoo {
    CloudComputing computingCloud;
    EdgeAliceComputing computingAlice;
}


import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/StandardToken.sol";

contract TheOneToken is StandardToken {
  string public constant name = "TheOneToken";
  string public constant symbol = "TOT";
  uint256 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 2100 ether;
  function TheOneToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

contract EdgeAliceToken {}

contract EdgeBobToken {}