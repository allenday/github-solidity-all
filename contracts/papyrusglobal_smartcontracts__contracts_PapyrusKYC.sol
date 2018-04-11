pragma solidity ^0.4.11;

import "./MultiAccess.sol";

/// @title Implements KYC manager that helps to manage KYC verification for addresses.
contract PapyrusKYC is MultiAccess {

    // EVENTS

    event KycRequirementChanged(address indexed participant, bool required);

    // PUBLIC FUNCTIONS

    /// @dev Returns true if KYC is required for specified address.
    /// @param _participant Address of the participant.
    function isKycRequired(address _participant) returns (bool) {
        require(_participant != address(0));
        return kycRequired[_participant];
    }

    /// @dev Sets KYC requirement for specified address.
    /// @param _participant Address of the participant.
    /// @param _required New value for KYC requirement.
    function setKycRequirement(address _participant, bool _required) accessGranted {
        require(_participant != address(0));
        if (!kycVerified[_participant]) {
            kycVerified[_participant] = !_required;
            kycRequired[_participant] = _required;
            KycRequirementChanged(_participant, _required);
        }
    }

    // FIELDS

    // Addresses which require KYC to be verified
    mapping(address => bool) public kycRequired;

    // Addresses that already where KYC verified
    mapping(address => bool) public kycVerified;
}
