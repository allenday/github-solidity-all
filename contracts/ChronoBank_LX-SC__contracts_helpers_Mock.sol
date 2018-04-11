/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;

contract Mock {

    event UnexpectedCall(uint index, address from, uint value, bytes input, bytes32 callHash);

    struct Expect {
        bytes32 callHash;
        bytes32 callReturn;
    }

    uint public expectationsCount;
    uint public nextExpectation = 1;
    uint public callsCount;
    mapping (uint => Expect) public expectations;
    mapping (bytes4 => bool) public ignores;

    function() public payable {
        if (ignores[msg.sig]) {
            assembly {
                mstore(0, 1)
                return (0, 32)
            }
        }
        callsCount++;
        bytes32 callHash = keccak256(msg.sender, msg.value, msg.data);
        if (expectations[nextExpectation].callHash != callHash) {
            UnexpectedCall(nextExpectation, msg.sender, msg.value, msg.data, callHash);
            return;
        }
        bytes32 result = expectations[nextExpectation++].callReturn;
        assembly {
            mstore(0, result)
            return (0, 32)
        }
    }

    function ignore(bytes4 _sig, bool _enabled) external {
        ignores[_sig] = _enabled;
    }

    function expect(address _from, uint _value, bytes _input, bytes32 _return) public {
        expectations[++expectationsCount] = Expect(keccak256(_from, _value, _input), _return);
    }

    function convertToBytes32(uint _value) public pure returns (bytes32) {
        return bytes32(_value);
    }

    function assertExpectations() public view {
        if (expectationsLeft() != 0 || callsCount != expectationsCount) {
            revert();
        }
    }

    function expectationsLeft() public view returns (uint) {
        return expectationsCount - (nextExpectation - 1);
    }

    function resetCallsCount() public {
        callsCount = 0;
    }
}
