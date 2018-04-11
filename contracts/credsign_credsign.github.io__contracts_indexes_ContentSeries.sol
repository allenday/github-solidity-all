pragma solidity ^0.4.3;

import "../Index.sol";
import "../Content.sol";

/// @title ContentSeries Index content in the order it is published.
contract ContentSeries is Index {

    /// @dev Series Store the index in the transaction logs.
    /// @param contentID The ID corresponding to the content.
    /// @param seriesNum A one-based, chronological index of all content.
    event Series (
        uint256 indexed contentID,
        uint256 indexed seriesNum,
        uint256 timestamp
    );

    mapping(uint256 => bool) contentIndexed;
    uint256 private contentSize;
    Content private content;

    /// @dev ContentSeries Construct a new content series index.
    /// @param contentContract Contract address where content gets published.
    function ContentSeries(address contentContract) {
        content = Content(contentContract);
    }

    /// @dev Add the contentID to this index.
    /// @param contentID the contentID for a piece of published content.
    function add(uint256 contentID) {
        uint256 timestamp = content.getTimestamp(contentID);
        if (timestamp == 0 || contentIndexed[contentID]) {
            // content doesn't exist; content is already indexed
            throw;
        }
        contentIndexed[contentID] = true;
        Series(
            contentID,
            ++contentSize,
            timestamp
        );
    }

    /// @dev Get the number of indexed content.
    /// @return The number of indexed content.
    function getSize() constant returns (uint256) {
        return contentSize;
    }

    /// @dev Reject any funds sent to the contract
    function() public {
        throw;
    }
}
