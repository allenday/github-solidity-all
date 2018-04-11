pragma solidity ^0.4.3;

import './Fund.sol';
import './Token.sol';

/// @title Content storage.
contract Feed {

    struct Content {
        uint256 block;
        uint256 funds;
        address token;
        address publisher;
        // TODO: publish content from different contracts
        // address contract;
    }

    /*
    Skipping account mgmt for now
    struct Account {
        address fundContract;
        mapping(uint256 => uint256) contentTips;
        mapping(address => uint256) tokenBalances;
    }*/

    event Publish (
        address indexed publisher,
        address indexed replyTo,
        address indexed token,
        uint256 contentID,
        uint256 parentID,
        uint256 timestamp
    );

    event Tip (
        uint256 indexed contentID,
        address indexed tipper,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );

    modifier onlyowner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    modifier listed(address token) {
        if (ChannelMinimums[token] == 0) {
            throw;
        }
        _;
    }

    /* Skip funding other tokens for now
    We'll introduce balance management later
    modifier fund(address token) {
        Account account = accounts[msg.sender];
        if (account.fundContract == 0) {
            account.fundContract = address(new Fund());
        }
        else if (token == 0) {
            account.tokenBalances[token] += Fund(account.fundContract).claimEther();
        }
        else {
            account.tokenBalances[token] += Fund(account.fundContract).claim(token);
        }
        _;
    }

    modifier sendEther() {
        if (msg.value > 0) {
            accounts[msg.sender].tokenBalances[0] += msg.value;
        }
        _;
    }*/

    //mapping(address => Account) private accounts;
    mapping(uint256 => Content) private contents;

    mapping(address => uint256[]) public AccountFeed;
    mapping(address => uint256[]) public ChannelFeed;
    mapping(uint256 => uint256[]) public ContentReplies;
    mapping(address => uint256) public ChannelMinimums;

    address public owner;
    address public publishAPI;

    function Feed() {
        owner = msg.sender;
    }

    /// @param publisher Address of the person publishing.
    /// @param contentID The contentID of this post.
    /// @param token The channel this post is published in.
    /// @param parentID The contentID this post is in response to.
    function publish(address publisher, uint256 contentID, address token, uint256 parentID) listed(token) returns(bool) {
        if (msg.sender != publishAPI) {
            throw;
        }

        Content content = contents[contentID];
        Content parent = contents[parentID];

        if (content.block != 0) {
            throw; // contentID collision
        }

        content.token = token;
        content.block = block.number;
        content.publisher = publisher;

        if (parentID == 0) {
            ChannelFeed[token].push(contentID);
        }
        else if (parent.block == 0 || parent.token != token) {
            throw; // not a valid reply
        }
        else {
            ContentReplies[parentID].push(contentID);
        }

        AccountFeed[publisher].push(contentID);

        Publish(
            publisher,
            parent.publisher,
            token,
            contentID,
            parentID,
            block.timestamp
        );
        return true;
    }

    function tip(uint256 contentID, address token, uint256 value) /* sendEther() fund(token) */ payable {
        Content content = contents[contentID];
        if (content.block == 0 || content.token != token || value < ChannelMinimums[token]
            || value != msg.value // So long as we're only dealing with Ether, check this
        ) {
            throw; // Invalid tip request
        }


        /* Skip the balance system for now and send the value directly
        Account tipper = accounts[msg.sender];
        Account author = accounts[content.publisher];
        if (tipper.tokenBalances[token] < value) {
            throw; // Insufficient funds
        }

        tipper.tokenBalances[token] -= value;
        author.tokenBalances[token] += value;
        */

        if (!content.publisher.send(value)) {
            throw;
        }

        content.funds += value;

        Tip(
            contentID,
            msg.sender,
            token,
            value,
            block.timestamp
        );
    }

    /* Skipping accoung balances for now
    function createAccountFundContract() {
        Account account = accounts[msg.sender];
        if (account.fundContract == 0) {
            account.fundContract = address(new Fund());
        }
    }

    function withdrawAccountBalance(address token) fund(token) {
        Account account = accounts[msg.sender];
        uint256 value = account.tokenBalances[token];
        account.tokenBalances[token] = 0;
        if (token == 0x0) {
            if (!msg.sender.send(value)) {
                throw;
            }
        }
        else {
            if (!Token(token).transfer(msg.sender, value)) {
                throw;
            }
        }
    }
    */

    function updatePublishContract(address publishContract) onlyowner() {
        publishAPI = publishContract;
    }

    function updateChannelMinimum(address token, uint256 minimum) onlyowner() {
        ChannelMinimums[token] = minimum;
    }

    /// @dev Reject any funds sent directly to the contract
    function() public {
        throw;
    }

    function getContent(uint256 contentID) constant returns (uint256, uint256, address, address, uint256) {
        Content content = contents[contentID];
        return (
            content.block,
            content.funds,
            content.token,
            content.publisher,
            ContentReplies[contentID].length
        );
    }

    function getReplyCount(uint256 contentID) constant returns (uint256) {
        return ContentReplies[contentID].length;
    }

    function getChannelSize(address token) constant returns (uint256) {
        return ChannelFeed[token].length;
    }

    function getAccountSize(address user) constant returns (uint256) {
        return AccountFeed[user].length;
    }
    /*
    function getAccountContentTip(address user, uint256 contentID) constant returns (uint256) {
        return accounts[user].contentTips[contentID];
    }

    function getAccountFundContract(address user) constant returns (address) {
        return accounts[user].fundContract;
    }

    function getAccountTokenBalance(address user, address token) constant returns (uint256) {
        Account account = accounts[user];
        uint256 balance = account.tokenBalances[token];
        if (account.fundContract > 0) {
            if (token == 0) {
                balance += Fund(account.fundContract).getEtherBalance();
            }
            else {
                balance += Fund(account.fundContract).getBalance(token);
            }
        }
        return balance;
    }*/

}
