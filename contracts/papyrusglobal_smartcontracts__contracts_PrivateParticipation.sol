pragma solidity ^0.4.11;

import "./zeppelin/ownership/Ownable.sol";
import "./zeppelin/token/BasicToken.sol";

/// @title Base support of private participation commonly used for auction contracts.
contract PrivateParticipation is Ownable {

    // EVENTS

    event PrivateParticipantUpdated(address indexed participant, uint256 amount);

    // PUBLIC FUNCTIONS

    /// @dev Allows specified address to participate in private stage of the auction.
    /// @param _participant Address of the participant of private stage of the auction.
    /// @param _amount Amount of weis allowed to bid for the participant.
    function allowPrivateParticipant(address _participant, uint256 _amount) onlyOwner {
        require(_participant != address(0));
        // _amount can be zero for cases when we want to disallow private participant
        privateParticipants[_participant] = _amount;
        PrivateParticipantUpdated(_participant, _amount);
    }

    // FIELDS

    // Addresses allowed to participate in private presale
    mapping(address => uint256) public privateParticipants;
}
