pragma solidity ^0.4.18;

import "./owned.sol";

/**
 * This smart contract keeps whether addresses are part of an organisation. Membership will expire
 * after a certain time unless it is renewed.
 */
contract ExpiringMembership is owned {

    event RegistrarAdded(address indexed owner, address indexed registrar, string description);
    event RegistrarRemoved(address indexed owner, address indexed registrar);
    event NewMemberRegistered(address indexed member, address indexed registrar, uint duration, uint expiryTimestamp);
    event MembershipExtended(address indexed member, address indexed registrar, uint duration, uint expiryTimestamp);
    event MembershipRevoked(address indexed member, address indexed revoker);

    /**
     * Membership status of an address. Currently only contains the expiry timestamp
     * of that membership.
     */
    struct Membership {
        uint expiryTimestamp;
    }

    /**
     * Which addresses are considered registrars. These addresses can be personal
     * accounts or can even be other smart contracts (like the EtherPaymentRegistrar).
     */
    mapping(address => bool) public isRegistrar;

    /**
     * Membership status for Ethereum addresses
     */
    mapping(address => Membership) public members;

    /**
     * Checks that the transaction source is a registrar or this contract's owner
     */
    modifier hasRegistrationPrivileges() {
        require(msg.sender == owner || isRegistrar[msg.sender]);
        _;
    }

    /*
     * Checks that the specified address is currently a member
     */
    modifier member(address _member) {
        require(isMember(_member));
        _;
    }

    function ExpiringMembership() {
        owner = msg.sender;
    }

    /**
     * Allows this contract's owner to add a new registrar. The description is
     * stored in this contract's event log.
     */
    function addRegistrar(address _registrar, string description) byOwner {
        if (isRegistrar[_registrar]) {
            return;
        }
        isRegistrar[_registrar] = true;
        RegistrarAdded(msg.sender, _registrar, description);
    }

    /**
     * Allows this contract's owner to remove a registrar.
     */
    function removeRegistrar(address _registrar) byOwner {
        if (!isRegistrar[_registrar]) {
            return;
        }
        isRegistrar[_registrar] = false;
        RegistrarRemoved(msg.sender, _registrar);
    }

    /**
     * Register or renew an address' membership. The membership token will last
     * for the given duration amount. When renewing a membership, the expiry date
     * will be EXTENDED and added to whatever the previous expiry date.
     *
     * This function can only be invoked by registrars or this contract's owner.
     */
    function enroll(address _member, uint duration) hasRegistrationPrivileges {
        if (isMember(_member)) {
           extendMembership(_member, duration);
        } else {
           registerNewMember(_member, duration);
        }
    }

    /**
     * Immediately revoke a member's membership.  This function can only be invoked
     * by registrars or this contract's owner
     */
    function revoke(address _member) hasRegistrationPrivileges {
        assert(isMember(_member));
        members[_member].expiryTimestamp = now;
        MembershipRevoked(_member, msg.sender);
    }

    function extendMembership(address _member, uint duration) private {
        var expiry = members[_member].expiryTimestamp + duration;
        members[_member].expiryTimestamp = expiry;
        MembershipExtended(_member, msg.sender, duration, expiry);
    }

    function registerNewMember(address _member, uint duration) private {
        var expiry = now + duration;
        members[_member].expiryTimestamp = expiry;
        NewMemberRegistered(_member, msg.sender, duration, expiry);
    }

    /**
     * Checks whether the specified address is currently a member
     */
    function isMember(address _member) constant returns (bool) {
        return now <= getMembershipExpiryDate(_member);
    }

    /**
     * Returns the expiry timestamp of the specified address' membership. If the
     * returned value is 0, that address was never a member
     */
    function getMembershipExpiryDate(address _member) constant returns (uint) {
        return members[_member].expiryTimestamp;
    }

}