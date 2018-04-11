/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;

/**
 * @title General MultiEventsHistory user.
 *
 */
contract MultiEventsHistoryAdapter {
    address eventsHistory;

    event Error(address indexed self, bytes32 msg);
    event ErrorCode(address indexed self, uint errorCode);

    function getEventsHistory() public view returns (address) {
        return eventsHistory;
    }

    function _setEventsHistory(address _eventsHistory) internal returns (bool) {
        eventsHistory = _eventsHistory;
        return true;
    }

    // It is address of MultiEventsHistory caller assuming we are inside of delegate call.
    function _self() view internal returns (address) {
        return msg.sender;
    }

    function _emitError(bytes32 _msg) internal {
        MultiEventsHistoryAdapter(getEventsHistory()).emitError(_msg);
    }

    function _emitErrorCode(uint _errorCode) internal returns (uint) {
        MultiEventsHistoryAdapter(getEventsHistory()).emitErrorCode(_errorCode);
        return _errorCode;
    }

    function emitError(bytes32 _msg) public {
        Error(_self(), _msg);
    }

    function emitErrorCode(uint _errorCode) public {
        ErrorCode(_self(), _errorCode);
    }
}
