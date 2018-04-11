/*
    multiOwner.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./safeMath.sol";

contract moduleMultiOwner {
    /* Variables */
    address public multiOwnerAddress;
    mapping(bytes32 => address[]) public doDB;
    /* Constructor */
    function moduleMultiOwner(address _multiOwnerAddress) {
        multiOwnerAddress = _multiOwnerAddress;
    }
    /* Internals */
    function insertAndCheckDo(bytes32 doHash) internal returns (bool success) {
        require( owners(msg.sender) );
        if (doDB[doHash].length >= ownersForChange()) {
            delete doDB[doHash];
            return true;
        }
        for ( uint256 a=0 ; a<doDB[doHash].length ; a++ ) {
            require( doDB[doHash][a] != msg.sender );
        }
        if ( doDB[doHash].length+1 >= ownersForChange() ) {
            delete doDB[doHash];
            return true;
        } else {
            doDB[doHash].push(msg.sender);
            return false;
        }
    }
    /* Constants */
    function ownersForChange() public constant returns (uint256 owners) {
        return multiOwner(multiOwnerAddress).ownersForChange();
    }
    function calcDoHash(string job, bytes32 data) public constant returns (bytes32 hash) {
        return sha3(job, data);
    }
    function owners(address addr) public constant returns (bool valid) {
        return multiOwner(multiOwnerAddress).owners(addr);
    }
    /* Modifiers */
    modifier onlyOwner() {
        /*
            Only the owner is allowed to call it.      
        */
        require( owners(msg.sender) );
        _;
    }
}

contract multiOwner is safeMath {
    /* Variables */
    uint256 public ownerCount;
    uint256 public constant doConfirmRate = 75;
    mapping(address => bool) public owners;
    mapping(bytes32 => address[]) public doDB;
    /* Constructor */
    function multiOwner(address[] newOwners) {
        for ( uint256 a=0 ; a<newOwners.length ; a++ ) {
            _addOwner(newOwners[a]);
        }
    }
    /* Externals */
    function insertOwner(address addr) external {
        require( ! owners[addr]);
        if ( insertAndCheckDo(calcDoHash("insertOwner", sha3(addr))) ) {
            _addOwner(addr);
        }
    }
    function dropOwner(address addr) external {
        require( owners[addr]);
        if ( insertAndCheckDo(calcDoHash("dropOwner", sha3(addr))) ) {
            _delOwner(addr);
        }
    }
    function cancelDo(bytes32 doHash) external {
        if ( insertAndCheckDo(calcDoHash("cancelDo", doHash)) ) {
            delete doDB[doHash];
        }
    }
    /* Internals */
    function insertAndCheckDo(bytes32 doHash) internal returns (bool success) {
        require( owners[msg.sender] );
        if (doDB[doHash].length >= ownersForChange()) {
            delete doDB[doHash];
            return true;
        }
        for ( uint256 a=0 ; a<doDB[doHash].length ; a++ ) {
            require( doDB[doHash][a] != msg.sender );
        }
        if ( doDB[doHash].length+1 >= ownersForChange() ) {
            delete doDB[doHash];
            return true;
        } else {
            doDB[doHash].push(msg.sender);
            return false;
        }
    }
    /* Constants */
    function ownersForChange() public constant returns (uint256 owners) {
        return ownerCount * doConfirmRate / 100;
    }
    function calcDoHash(string job, bytes32 data) public constant returns (bytes32 hash) {
        return sha3(job, data);
    }
    function validDoHash(bytes32 doHash) public constant returns (bool valid) {
        return doDB[doHash].length > 0;
    }
    function hashAddress(address addr) public constant returns (bytes32 hash) {
        return sha3(addr);
    }
    /* Privates */
    function _addOwner(address addr) private {
        if ( owners[addr] ) { return; }
        owners[addr] = true;
        ownerCount = safeAdd(ownerCount, 1);
    }
    function _delOwner(address addr) private {
        if ( ! owners[addr] ) { return; }
        require( ownerCount > 1 );
        delete owners[addr];
        ownerCount = safeSub(ownerCount, 1);
    }
}
