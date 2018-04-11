pragma solidity ^0.4.13;

import "./Owned.sol";

contract SecuredWithRoles is Owned {
    Roles public roles;
    bytes32 public contractHash;
    bool public stopped = false;

    function SecuredWithRoles(string contractName_, address roles_) {
        contractHash = keccak256(contractName_);
        roles = Roles(roles_);
    }

    modifier stoppable() {
        require(!stopped);
        _;
    }

    modifier onlyRole(string role) {
        require(senderHasRole(role));
        _;
    }

    modifier roleOrOwner(string role) {
        require(msg.sender == owner || senderHasRole(role));
        _;
    }

    // returns true if the role has been defined for the contract
    function hasRole(string roleName) constant returns (bool) {
        return roles.knownRoleNames(contractHash, keccak256(roleName));
    }

    function senderHasRole(string roleName) constant returns (bool) {
        return roles.roleList(contractHash, keccak256(roleName), msg.sender);
    }

    function stop() roleOrOwner("stopper") {
        stopped = true;
    }

    function restart() roleOrOwner("restarter") {
        stopped = false;
    }

    function setRolesContract(address roles_) onlyOwner {
        // it must not be possible to change the roles contract on the roles contract itself
        require(this != roles);
        roles = Roles(roles_);
    }

}


contract RolesEvents {
    event LogRoleAdded(bytes32 contractHash, string roleName);
    event LogRoleRemoved(bytes32 contractHash, string roleName);
    event LogRoleGranted(bytes32 contractHash, string roleName, address user);
    event LogRoleRevoked(bytes32 contractHash, string roleName, address user);
}


contract Roles is RolesEvents, SecuredWithRoles {
    // mapping is contract -> role -> sender_address -> boolean
    mapping(bytes32 => mapping (bytes32 => mapping (address => bool))) public roleList;
    // the intention is
    mapping (bytes32 => mapping (bytes32 => bool)) public knownRoleNames;

    function Roles() SecuredWithRoles("RolesRepository", this) {
    }

    function addContractRole(bytes32 ctrct, string roleName) roleOrOwner("admin") {
        require(!knownRoleNames[ctrct][keccak256(roleName)]);
        knownRoleNames[ctrct][keccak256(roleName)] = true;
        LogRoleAdded(ctrct, roleName);
    }

    function removeContractRole(bytes32 ctrct, string roleName) roleOrOwner("admin") {
        require(knownRoleNames[ctrct][keccak256(roleName)]);
        knownRoleNames[ctrct][keccak256(roleName)] = false;
        LogRoleRemoved(ctrct, roleName);
    }

    function grantUserRole(bytes32 ctrct, string roleName, address user) roleOrOwner("admin") {
        require(knownRoleNames[ctrct][keccak256(roleName)]);
        knownRoleNames[ctrct][keccak256(roleName)] = true;
        roleList[ctrct][keccak256(roleName)][user] = true;
        LogRoleGranted(ctrct, roleName, user);
    }

    function revokeUserRole(bytes32 ctrct, string roleName, address user) roleOrOwner("admin") {
        roleList[ctrct][keccak256(roleName)][user] = false;
        LogRoleRevoked(ctrct, roleName, user);
    }

}
