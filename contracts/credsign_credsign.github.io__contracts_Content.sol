pragma solidity ^0.4.3;

import "./Index.sol";

/// @title Content storage engine for publishing.
contract Content {

    // Keep content attribute data in storage.
    struct Attributes {
        address publisher;
        uint256 channelID;
        uint256 timestamp;
    }

    /// @dev Publish content to the transaction logs
    /// @param contentID The unique contentID generated for this content.
    /// @param publisher The address the content was published from.
    /// @param channelID The numeric representation of a valid channel.
    /// @param header JSON string containing title and metadata.
    /// @param body Blob of data containing the published body.
    /// @return timestamp The block timestamp of the published content.
    event Publish (
        uint256 indexed contentID,
        address indexed publisher,
        uint256 indexed channelID,
        string header,
        bytes body,
        uint256 timestamp
    );

    // Each contentID maps to its content attributes.
    mapping(uint256 => Attributes) private attributes;

    // @dev Create a new publishing contract.
    function Content() { }

    /// @notice Publishing is final and irreversible.
    /// @dev Publish content, adding it to zero or more indexes.
    /// @param channel The channel into which the content gets published.
    /// @param header JSON string containing title and metadata.
    /// @param body Blob of data containing the published body.
    /// @param indexes Array of indexes to add the content to.
    function publish(string channel, string header, bytes body, address[] indexes) {
        uint256 channelID = toChannelID(channel);
        uint256 contentID = toContentID(msg.sender, channelID, header, body);

        // Non-zero attributes indicate an id collision, bail.
        if (attributes[contentID].timestamp != 0) {
            throw;
        }

        attributes[contentID] = Attributes({
            publisher: msg.sender,
            channelID: channelID,
            timestamp: block.timestamp
        });

        Publish(
            contentID,
            msg.sender,
            channelID,
            header,
            body,
            block.timestamp
        );

        for (uint256 i = 0; i < indexes.length; i++) {
            Index(indexes[i]).add(contentID);
        }
    }

    /// @dev Generate a deterministic contentID from the content data.
    /// @param publisher The address the content is published from.
    /// @param channelID The channelID generated from `toChannelID(channel)`.
    /// @param header JSON string containing title and metadata.
    /// @param body Blob of data containing the published body.
    /// @return contentID A keccak256 digest of the publishing params.
    function toContentID(address publisher, uint256 channelID, string header, bytes body) constant returns (uint256) {
        return uint256(keccak256(publisher, channelID, header, body));
    }
    /// @dev Convert a valid channel to its id representation.
    /// @param channel Must only consist of letters, numbers, underscores and be 3-30 bytes long.
    /// @return channelID The numeric representation of a valid channel, otherwise throws.
    function toChannelID(string channel) constant returns (uint256 channelID) {
        bytes memory raw = bytes(channel);
        if (raw.length < 3 || raw.length > 30) {
            throw;
        }
        for (uint256 i = 0; i < raw.length; i++) {
            uint8 c = uint8(raw[i]);
            if (
                (c >= 48 && c <= 57) || // [0-9]
                (c >= 97 && c <= 122) || // [a-z]
                c == 95 // [_]
            ) {
                // Shift by 1 byte (*2^8) and add char
                channelID *= 256;
                channelID += c;
            }
            else if (c >= 65 && c <= 90) { // [A-Z]
                // Shift by 1 byte (*2^8) and add lowercase char
                channelID *= 256;
                channelID += c + 32; // 32 = a - A
            }
            else {
                throw;
            }
        }
        return channelID;
    }

    /// @dev Get the publisher of a piece of content.
    /// @param contentID the contentID for a piece of published content.
    /// @return publisher The address the content was published from.
    function getPublisher(uint256 contentID) constant returns (address) {
        return attributes[contentID].publisher;
    }

    /// @dev Get the published content's channelID.
    /// @param contentID the contentID for a piece of published content.
    /// @return channelID The channelID the content was published to.
    function getChannelID(uint256 contentID) constant returns (uint256) {
        return attributes[contentID].channelID;
    }

    /// @dev Get the published content's timestamp.
    /// @param contentID the contentID for a piece of published content.
    /// @return timestamp The block timestamp of the published content.
    function getTimestamp(uint256 contentID) constant returns (uint256) {
        return attributes[contentID].timestamp;
    }

    /// @dev Get all the published content's attributes.
    /// @param contentID the contentID for a piece of published content.
    /// @return publisher The address the content was published from.
    /// @return channelID The channelID the content was published to.
    /// @return timestamp The block timestamp of the published content.
    function getAttributes(uint256 contentID) constant returns (address, uint256, uint256) {
        Attributes a = attributes[contentID];
        return (a.publisher, a.channelID, a.timestamp);
    }

    /// @dev Reject any funds sent to the contract
    function() public {
        throw;
    }
}
