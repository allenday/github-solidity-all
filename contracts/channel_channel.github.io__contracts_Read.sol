pragma solidity ^0.4.3;

import './Feed.sol';

contract Read {

    Feed private feed;

    modifier ignore(uint256 cacheBust) {
        _;
    }

    function Read(address feedContract) {
        feed = Feed(feedContract);
    }

    function getChannelFeed(address token, uint256 offset, uint256 limit, uint256 cacheBust) ignore(cacheBust) constant returns (uint256[]) {
        if (offset + limit > feed.getChannelSize(token)) {
            throw;
        }
        uint256[] memory contentIDs = new uint256[](limit);
        for (uint256 i = 0; i < limit; i++) {
            contentIDs[i] = feed.ChannelFeed(token, offset + i);
        }
        return contentIDs;
    }

    function getAccountFeed(address user, uint256 offset, uint256 limit, uint256 cacheBust) ignore(cacheBust) constant returns (uint256[]) {
        if (offset + limit > feed.getAccountSize(user)) {
            throw;
        }
        uint256[] memory contentIDs = new uint256[](limit);
        for (uint256 i = 0; i < limit; i++) {
            contentIDs[i] = feed.AccountFeed(user, offset + i);
        }
        return contentIDs;
    }

    function getContentReplies(uint256 contentID, uint256 cacheBust) ignore(cacheBust) constant returns (uint256[]) {
        uint256[] memory contentIDs = new uint256[](feed.getReplyCount(contentID));
        for (uint256 i = 0; i < contentIDs.length; i++) {
            contentIDs[i] = feed.ContentReplies(contentID, i);
        }
        return contentIDs;
    }

    function getContents(uint256[] contentIDs, uint256 cacheBust) ignore(cacheBust) constant returns (uint256[], uint256[], address[], address[], uint256[]) {
        uint256[] memory blocks = new uint256[](contentIDs.length);
        uint256[] memory funds = new uint256[](contentIDs.length);
        address[] memory tokens = new address[](contentIDs.length);
        address[] memory publishers = new address[](contentIDs.length);
        uint256[] memory replyCounts = new uint256[](contentIDs.length);
        for (uint256 i = 0; i < contentIDs.length; i++) {
            (   blocks[i],
                funds[i],
                tokens[i],
                publishers[i],
                replyCounts[i]
            ) = feed.getContent(contentIDs[i]);
        }
        return (blocks, funds, tokens, publishers, replyCounts);
    }

    function getChannelSize(address token, uint256 cacheBust) ignore(cacheBust) constant returns (uint256) {
        return feed.getChannelSize(token);
    }

    function getAccountSize(address user, uint256 cacheBust) ignore(cacheBust) constant returns (uint256) {
        return feed.getAccountSize(user);
    }

}
