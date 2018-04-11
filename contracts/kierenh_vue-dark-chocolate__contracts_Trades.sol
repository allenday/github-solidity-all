pragma solidity ^0.4.2;

import './Owned.sol';

//
// Tracks relationships between accounts and "trades", such as between an account and trades.
// This is really just a convenient way to look-up those related accounts (in an efficient/indexed mannger, as opposed to iterating through all trades etc.)
//
contract Trades is Owned {

    struct TradeAssociation {
        // These arrays represent "keys" to look-up in each respective set
        // e.g. for address: 0xABC: ['abc', 'def', 'hij']
        // You can query, how many "things" does 0xABC have: 3
        // Then you can get the key of each "thing" by index [0, 1, 2]
        // And you can use the index to look-up "things" via their respective contract/manager
        // So to that effect:
        // addMethods takes an address and "key"
        // getMethods take an address an index (which gives you back a key)
        bytes32[] sentTrades;
        bytes32[] receivedTrades;
    }

    mapping(address => TradeAssociation) tradeAssociations;

    function addSentTrade(address account, bytes32 referenceCode) public
    {
        tradeAssociations[account].sentTrades.push(referenceCode);
    }

    function getSentTrade(address account, uint index) public constant
    returns (bytes32)
    {
        require(account != 0x0 && index >= 0 && index < tradeAssociations[account].sentTrades.length);

        return tradeAssociations[account].sentTrades[index];
    }

    function addReceivedTrade(address account, bytes32 referenceCode) public
    {
        tradeAssociations[account].receivedTrades.push(referenceCode);
    }

    function getReceivedTrade(address account, uint index) public constant
    returns (bytes32)
    {
        require(account != 0x0 && index >= 0 && index < tradeAssociations[account].receivedTrades.length);

        return tradeAssociations[account].receivedTrades[index];
    }

    function getCounts(address account) public constant
        returns (uint sentTradesCount, uint receivedTradesCount)
    {
        TradeAssociation memory tradeAssociation = tradeAssociations[account];

        return (tradeAssociation.sentTrades.length,
            tradeAssociation.receivedTrades.length);
    }
}
