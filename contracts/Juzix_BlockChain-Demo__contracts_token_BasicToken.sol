 pragma solidity ^0.4.2;

import './ERC20Basic.sol';
import '../utillib/LibPaillier.sol';
contract BasicToken is ERC20Basic {

    mapping(address => uint256) balances;

    function transfer(address _to, uint256 _value) returns (bool) {}

    function balanceOf(address _owner) constant returns (uint256 balance) {}

    //function totalSupply() constant returns (uint256 supply) {}

}
 