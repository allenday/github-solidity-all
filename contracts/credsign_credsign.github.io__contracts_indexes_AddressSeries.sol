pragma solidity ^0.4.3;

import "../Index.sol";
import "../Content.sol";

/// @title AddressSeries Index content in the order it is published by an address.
contract AddressSeries is Index {

    /// @dev Series Store the index in the transaction logs.
    /// @param contentID The ID corresponding to the content.
    /// @param publisher The address that published content.
    /// @param seriesNum A one-based, chronological index of the publisher's content.
    /// @param channelID The ID corresponding to channel the content is published in.
    /// @param timestamp The block timestamp for merging the series from multiple publishers.
    event Series (
        uint256 indexed contentID,
        address indexed publisher,
        uint256 indexed seriesNum,
        uint256 channelID,
        uint256 timestamp
    );

    mapping(uint256 => bool) contentIndexed;
    mapping(address => uint256) addressSize;
    Content private content;

    /// @dev AddressSeries Construct a new publisher series index.
    /// @param contentContract Contract address where content gets published.
    function AddressSeries(address contentContract) {
        content = Content(contentContract);
    }

    /// @dev Add the contentID to this index.
    /// @param contentID the contentID for a piece of published content.
    function add(uint256 contentID) {
        var (publisher, channelID, timestamp) = content.getAttributes(contentID);
        if (timestamp == 0 || contentIndexed[contentID]) {
            // content doesn't exist; content is already indexed
            throw;
        }
        contentIndexed[contentID] = true;
        Series(
            contentID,
            publisher,
            ++addressSize[publisher],
            channelID,
            timestamp
        );
    }

    /// @dev Get the number of indexed content published by the publisher.
    /// @param publisher The address of the publisher.
    /// @return The number of indexed content published by the publisher.
    function getSize(address publisher) constant returns (uint256) {
        return addressSize[publisher];
    }

    /// @dev Reject any funds sent to the contract
    function() public {
        throw;
    }
}
