pragma solidity ^0.4.11;

import './ERC20Basic.sol';

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint indexed value);
}