/*
    tokenDB.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./safeMath.sol";
import "./owned.sol";

contract tokenDB is safeMath, owned {
    /* Structures */
    struct allowance_s {
        uint256 amount;
        uint256 nonce;
    }
    /* Variables */
    mapping(address => mapping(address => allowance_s)) public allowance;
    mapping (address => uint256) public balanceOf;
    uint256 public totalSupply;
    /* Externals */
    function increase(address owner, uint256 value) external returns(bool success) {
        /*
            Increase of balance of the address in database. Only owner can call it.
            
            @owner          Address
            @value          Quantity
            
            @success        Was the Function successful?
        */
        require( isOwner() );
        balanceOf[owner] = safeAdd(balanceOf[owner], value);
        totalSupply = safeAdd(totalSupply, value);
        return true;
    }
    function decrease(address owner, uint256 value) external returns(bool success) {
        /*
            Decrease of balance of the address in database. Only owner can call it.
            
            @owner          Address
            @value          Quantity
            
            @success        Was the Function successful?
        */
        require( isOwner() );
        balanceOf[owner] = safeSub(balanceOf[owner], value);
        totalSupply = safeSub(totalSupply, value);
        return true;
    }
    function setAllowance(address owner, address spender, uint256 amount, uint256 nonce) external returns(bool success) {
        /*
            Set allowance in the database. Only owner can call it.
            
            @owner          Owner address
            @spender        Spender address
            @amount         Amount to set
            @nonce          Transaction count
            
            @success        Was the Function successful?
        */
        require( isOwner() );
        allowance[owner][spender].amount = amount;
        allowance[owner][spender].nonce = nonce;
        return true;
    }
    /* Constants */
    function getAllowance(address owner, address spender) constant returns(bool success, uint256 remaining, uint256 nonce) {
        /*
            Get allowance from the database.
            
            @owner          Owner address
            @spender        Spender address
            
            @success        Was the Function successful?
            @remaining      Remaining amount of the allowance
            @nonce          Transaction count
        */
        return ( true, allowance[owner][spender].amount, allowance[owner][spender].nonce );
    }
}
