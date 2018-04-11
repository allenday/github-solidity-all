pragma solidity ^0.4.3;

/// @title Identity Associate an address with an arbitrary identifier.
contract Identity {

    /// @dev Emit an event whenever an identity is registered.
    /// @param owner The address registering an identity.
    /// @param identity The identity to associate with the address.
    /// @param timestamp The block timestamp of registration.
    event Register(
        address indexed owner,
        uint256 indexed identity,
        uint256 timestamp
    );

    mapping(address => uint256) private identities;

    // @dev Create a new identity management contract.
    function Identity() { }

    /// @dev Associate an address with an identity.
    /// @param identity The identity to associate with `msg.sender`.
    function register(uint256 identity) {
        identities[msg.sender] = identity;
        Register(msg.sender, identity, block.timestamp);
    }

    /// @dev Identify an address.
    /// @param owner The address to lookup.
    /// @return identity The identity corresponding to the address.
    function identify(address owner) constant returns (uint256) {
        return identities[owner];
    }

    /// @dev Reject any funds sent to the contract
    function() public {
        throw;
    }
}
