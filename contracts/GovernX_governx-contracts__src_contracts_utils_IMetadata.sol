pragma solidity 0.4.16;

// a special Owned contract interface with trander method
contract IMetadata {
  function name() public constant returns(string);
  function version() public constant returns(string);
}
