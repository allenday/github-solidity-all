pragma solidity ^0.4.11;

import "./Owned.sol";

/**
 * Ledger - overflow-safe ledger contract
 */
contract Ledger is Allowable {
    
    mapping(address => uint) public gains;
    mapping(address => uint) public locked;
    mapping(address => uint) public pending;
    
    modifier checkInvariant(address account){
        require(invariant(account));
        _;
        require(invariant(account));
    }
    
    modifier checkSpace(address account, uint amount){
        require(freeSpaceOf(account) >= amount);
        _;
    }
    
    modifier checkPending(address account, uint amount){
        require(pending[account] >= amount);
        _;
    }
    
    modifier checkLocked(address account, uint amount){
        require(locked[account] >= amount);
        _;
    }
    
    modifier checkGains(address account, uint amount){
        require(gains[account] >= amount);
        _;
    }

    function addPending(address account, uint amount)
    external 
    onlyAllowed
    checkInvariant(account)
    checkSpace(account, amount)
    {
        pending[account] += amount;
    }
    
    function removePending(address account, uint amount)
    external 
    onlyAllowed
    checkInvariant(account)
    checkPending(account, amount)
    {
        pending[account] -= amount;
    }
    
    function addLocked(address account, uint amount)
    external 
    onlyAllowed
    checkInvariant(account)
    checkSpace(account, amount)
    {
        locked[account] += amount;
    }
    
    function removeLocked(address account, uint amount)
    external 
    onlyAllowed
    checkInvariant(account)
    checkLocked(account, amount)
    {
        locked[account] -= amount;
    }
    
    function addGains(address account, uint amount)
    external 
    onlyAllowed
    checkInvariant(account)
    checkSpace(account, amount)
    {
        gains[account] += amount;
    }
    
    function removeGains(address account, uint amount)
    external 
    onlyAllowed
    checkInvariant(account)
    checkGains(account, amount)
    {
        gains[account] -= amount;
    }
    
    function balanceOf(address account) constant public returns (uint) {
        return locked[account] + pending[account];
    }
    
    function supplyOf(address account) constant public returns (uint) {
        return gains[account] + locked[account] + pending[account];
    }
    
    function freeSpaceOf(address account) constant public returns (uint) {
        return uint256(-1) - supplyOf(account);
    }
    
    function invariant(address account) constant private returns (bool value) {
        value = pending[account] <= balanceOf(account) &&
                balanceOf(account) <= supplyOf(account);
    }
    
    function() { revert(); }
    
}