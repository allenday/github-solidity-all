pragma solidity ^0.4.2;

import './Owned.sol';
import './KeyedCollection.sol';

//
// Defines the contract for trades.
//
contract TradeManager is Owned, KeyedCollection {

    enum TradeStatus { Created, CounterpartyCertified, CounterpartyRejected }
    TradeStatus constant DEFAULT_TRADE_STATUS = TradeStatus.Created;

    struct Trade {
        bytes32 referenceCode;
        uint issueDate;
        TradeStatus status;
        address vendor;
        address counterparty;
        bool isValue;
        uint offerAccepted;
        uint offerExpiry;
    }

    // Trades by reference code
    mapping (bytes32 => Trade) private trades;

    function exists(bytes32 key) public constant
        returns(bool)
    {
        if (keys.length == 0) {
            return false;
        }
        return (trades[key].isValue);
    }

    function insert(bytes32 referenceCode, uint issueDate, uint offerExpiry, address vendor, address counterparty) public
        returns(uint index)
    {
        require(!exists(referenceCode));

        Trade memory trade = Trade({
            referenceCode: referenceCode,
            issueDate: issueDate,
            status: DEFAULT_TRADE_STATUS,
            offerExpiry: offerExpiry,
            vendor: vendor,
            counterparty: counterparty,
            isValue: true,
            offerAccepted: 0x0
        });
        trades[referenceCode] = trade;

        return super.addKey(referenceCode);
    }

    function getByIndex(uint index) public constant
        returns(bytes32, uint, uint, uint, TradeStatus, address, address)
    {
        require(index >= 0 && index < keys.length);

        return getByReferenceCode(keys[index]);
    }

    function getByReferenceCode(bytes32 referenceCode) public constant
        returns(bytes32, uint, uint, uint, TradeStatus, address, address)
    {
        require(exists(referenceCode));

        Trade memory trade;
        trade = trades[referenceCode];

        return(trade.referenceCode, trade.issueDate, trade.offerExpiry, trade.offerAccepted, trade.status, trade.vendor, trade.counterparty);
    }

    function updateStatus(bytes32 referenceCode, uint offerAccepted, TradeStatus status) public
    {
        require(exists(referenceCode));
        // super basic validation to enforce the workflow
        // created -> counterparty certified || counterparty rejected -> etc.

        Trade memory trade = trades[referenceCode];
        require(now < trade.offerExpiry);

        if (trade.status == TradeManager.TradeStatus.Created) {
            require(status == TradeStatus.CounterpartyCertified || status == TradeStatus.CounterpartyRejected);
        } else {
            // Invalid status transition
            assert(false);
        }

        trades[referenceCode].status = status;
        trades[referenceCode].offerAccepted = offerAccepted;
        trades[referenceCode].offerExpiry = 0x0;
    }
}
