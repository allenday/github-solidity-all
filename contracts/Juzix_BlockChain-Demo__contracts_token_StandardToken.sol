pragma solidity ^0.4.2;

import './BasicToken.sol';
import './ERC20.sol';

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;

    // ===================================================================================
    /// @dev ERC20.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {} 

    /// @dev ERC20.
    function approve(address _spender, uint256 _value) returns (bool) {}

    /// @dev ERC20.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

}
