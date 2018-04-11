/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.11;


contract BitOps {

    // TODO: add error code for modifiers

    modifier singleFlag(uint _flag) {
        if (!_isSingleFlag(_flag)) {
            return;
        }
        _;
    }

    modifier singleOddFlag(uint _flag) {
        if (!_isSingleFlag(_flag) || !_isOddFlag(_flag)) {
            return;
        }
        _;
    }

    modifier ifEvenThenOddTooFlags(uint _flags) {
        if (!_ifEvenThenOddTooFlags(_flags)) {
            return;
        }
        _;
    }

    modifier hasFlags(uint _flags) {
        if (_flags == 0) {
            return;
        }
        _;
    }


    function _hasFlag(uint _flags, uint _flag) internal pure returns(bool) {
        return _flags & _flag != 0;
    }

    function _hasFlags(uint _flags, uint _flagsToCheck) internal pure returns(bool) {
        return _flags & _flagsToCheck == _flagsToCheck;
    }

    function _isSingleFlag(uint _flag) internal pure returns(bool) {
        return _flag != 0 && (_flag & (_flag - 1) == 0);
    }

    function _isOddFlag(uint _flag) internal pure returns(bool) {
        return _flag & 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa == 0;
    }

    function _isFullOrNull(uint _flags, uint _flag) internal pure returns(bool) {
        return !_hasFlag(_flags, _flag) || _hasFlag(_flags, _flag << 1);
    }

    function _ifEvenThenOddTooFlags(uint _flags) internal pure returns(bool) {
        uint flagsEvenOddMask = (_flags & 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa) >> 1;
        return (_flags & flagsEvenOddMask) == flagsEvenOddMask;
    }
}
