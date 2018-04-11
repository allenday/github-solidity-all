pragma solidity ^0.4.2;

import './Owned.sol';
import './Trades.sol';
import './TradeManager.sol';

//
// Defines the Trade Register contract. This is the entry point to rergister trades.
//
contract TradeRegister is Owned {

    // Depends on these guys contracts
    address private trades;
    address private tradeManager;

    function TradeRegister() Owned() {
        trades = new Trades();
        tradeManager = new TradeManager();
    }

    modifier requireTraders(address vendor, address counterparty) {
        require(vendor != 0x0 && counterparty != 0x0);
        _;
    }

    function getTradesByAddress(address trader)
        restricted(trader)
        public constant returns(bytes32[] sentTradeIds, bytes32[] receivedTradeIds)
    {
        var (sentTradesCount, receivedTradesCount) = Trades(trades).getCounts(trader);

        uint i;

        // Sent and received trades
        sentTradeIds = new bytes32[](sentTradesCount);
        for (i = 0; i < sentTradesCount; ++i) {
            sentTradeIds[i] = Trades(trades).getSentTrade(trader, i);
        }
        receivedTradeIds = new bytes32[](receivedTradesCount);
        for (i = 0; i < receivedTradesCount; ++i) {
            receivedTradeIds[i] = Trades(trades).getReceivedTrade(trader, i);
        }

        return (sentTradeIds, receivedTradeIds);
    }

    event TradeRegistered(bytes32 referenceCode, uint issueDate, uint offerExpiry, address indexed vendor, address indexed counterparty);
    event TradeCertified(bytes32 referenceCode, uint offerAccepted, TradeManager.TradeStatus status, address indexed vendor, address indexed counterparty);

    function createTrade(bytes32 referenceCode, uint issueDate, uint offerExpiry, address vendor, address counterparty)
        restricted(vendor) // The seller enters this trade...
        requireTraders(vendor, counterparty)
        public
        returns(uint index)
    {
        index = TradeManager(tradeManager).insert(referenceCode, issueDate, offerExpiry, vendor, counterparty);

        Trades(trades).addSentTrade(vendor, referenceCode);
        Trades(trades).addReceivedTrade(counterparty, referenceCode);

        TradeRegistered(referenceCode, issueDate, offerExpiry, vendor, counterparty);

        return index;
    }

    function certifyTradeAsCounterparty(bytes32 referenceCode, address counterparty)
    restricted(counterparty)
    public {
        var (, , , vendor, tradeCounterparty) = getTradeByReferenceCode(referenceCode);
        require(tradeCounterparty == counterparty);

        uint offerAccepted = now;
        TradeManager(tradeManager).updateStatus(referenceCode, offerAccepted, TradeManager.TradeStatus.CounterpartyCertified);

        TradeCertified(referenceCode, offerAccepted, TradeManager.TradeStatus.CounterpartyCertified, vendor, counterparty);
    }

    function getTradeByReferenceCode(bytes32 referenceCode) public constant
        returns(bytes32, uint, uint, uint, TradeManager.TradeStatus, address, address)
    {
        return TradeManager(tradeManager).getByReferenceCode(referenceCode);
    }

    function getTradeByIndex(uint index) public constant
        returns(bytes32, uint, uint, uint, TradeManager.TradeStatus, address, address)
    {
        return TradeManager(tradeManager).getByIndex(index);
    }

    function getTradeCount() public constant
        returns(uint count)
    {
        return TradeManager(tradeManager).getCount();
    }
}
