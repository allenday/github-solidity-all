pragma solidity ^0.4.4;
import 'contracts/Arthimetic.sol';
//import "http://github.com/Arachnid/solidity-stringutils/strings.sol" ;
contract Scientific {
  function Scientific() public {
    // constructor
  }

  function  squareOfSums(uint x, uint y) public returns (uint) {
    var arth = new Arthimetic ();
    var res = arth.add(x,y);
    return res * res;
  }

  /*function startsWith(string original, string prefix) returns (bool) {
    return original.toSlice().startsWith(prefix.toSlice());
  }*/
}
