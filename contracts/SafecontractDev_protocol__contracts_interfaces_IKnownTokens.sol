pragma solidity ^0.4.15;

contract IKnownTokens {
    function recoverPrice(address _token1, address _token2) public constant returns (uint);
    function addToken(address _tokenAddr) public;
    function containsToken(address _token) public constant returns (bool);
}