pragma solidity ^0.4.11;


contract IMintableToken {
    function mint(address _to, uint256 _amount) returns (bool);
    function finishMinting() returns (bool);
}
