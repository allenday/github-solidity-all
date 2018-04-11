pragma solidity ^0.4.11;

import "./Owned.sol";

/**
 * UUID - Database item hash ID contract
 */
contract UUID is Allowable {
    
    mapping(bytes32 => bool) public exists;
    uint public nonce = 0;
    
    modifier mustExist(bytes32 id) {
        require(exists[id]);
        _;
    }
    
    modifier validAccount(address account) {
        require(account != address(0));
        _;
    }
    
    function setExists(bytes32 id, bool value) external onlyAllowed {
        exists[id] = value;
    }
    
    function new_id() 
    external
    onlyAllowed
    returns(bytes32)
    {
        return sha3(this, block.number, nonce++);
    }
    
    function deleteItem(bytes32 id) external onlyAllowed mustExist(id) {
        deleteHelper(id);
    }
    
    function deleteHelper(bytes32 id) internal {
        delete exists[id];
    }
    
    function() { revert(); }
}