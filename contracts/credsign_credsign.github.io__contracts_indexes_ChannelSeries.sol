pragma solidity ^0.4.3;

import "../Index.sol";
import "../Content.sol";

/// @title ChannelSeries Index content in the order it is published in a channel.
contract ChannelSeries is Index {

    /// @dev Series Store the index in the transaction logs.
    /// @param contentID The ID corresponding to the content.
    /// @param channelID The ID corresponding to channel the content is published in.
    /// @param seriesNum A one-based, chronological index of content in a channel.
    event Series (
        uint256 indexed contentID,
        uint256 indexed channelID,
        uint256 indexed seriesNum,
        uint256 timestamp
    );

    mapping(uint256 => bool) contentIndexed;
    mapping(uint256 => uint256) channelSize;
    Content private content;

    /// @dev ChannelSeries Construct a new channel series index.
    /// @param contentContract The contract where content gets published.
    function ChannelSeries(address contentContract) {
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
            channelID,
            ++channelSize[channelID],
            timestamp
        );
    }

    /// @dev Get the number of indexed content in the channel.
    /// @param channelID The address of the publisher.
    /// @return The number of indexed content in the channel.
    function getSize(uint256 channelID) constant returns (uint256) {
        return channelSize[channelID];
    }

    /// @dev Reject any funds sent to the contract
    function() public {
        throw;
    }
}
