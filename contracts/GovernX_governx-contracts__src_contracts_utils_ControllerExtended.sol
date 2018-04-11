pragma solidity ^0.4.16;

import "utils/Controller.sol";


contract ControllerExtended is Controller {

    function latestSenderOf(uint256 _proposalID) internal constant returns (address) {
        return momentSenderOf(_proposalID, numMomentsOf(_proposalID) - 1);
    }

    function executionTimeOf(uint256 _proposalID) internal constant returns (uint256) {
        if (hasExecuted(_proposalID))
            return momentTimeOf(_proposalID, numMomentsOf(_proposalID) - 1);
    }

    function executionBlockOf(uint256 _proposalID) internal constant returns (uint256) {
        if (hasExecuted(_proposalID))
            return momentBlockOf(_proposalID, numMomentsOf(_proposalID) - 1);
    }

    function destinationOf(uint256 _proposalID, uint256 _startPosition) internal constant returns (address) {
        bytes memory data = proposals[_proposalID].data;

        assembly {
            // make sure we don’t overstep array boundaries because in assembly
            // there’s no built-in boundary checks
            // We’re basically comparing _startPosition to the length of the array
            // (stored in the first 32 bytes) and subtracting the length of an address
            switch lt(_startPosition, sub(mload(data), 32))
            case 0 { stop }

            // Let’s just load the 20 bytes following the _startPosition byte
            // and return them. Simple as that!
            //
            //NOTE: we have to add an additional 32 bytes to account for the
            // 32 bytes specifying the length of the array at the beggining.
            let start := add(data, add(_startPosition, 0x20))
            return(start, 0x14)
        }
    }

    function valueOf(uint256 _proposalID, uint256 _startPosition) internal constant returns (uint256) {
        bytes memory data = proposals[_proposalID].data;

        assembly {
            // make sure we don’t overstep array boundaries because in assembly
            // there’s no built-in boundary checks
            // We’re basically comparing _startPosition to the length of the array
            // (stored in the first 32 bytes) and subtracting the length of an uint
            switch lt(_startPosition, sub(mload(data), 32))
            case 0 { stop }

            // Let’s just load the 32 bytes following the _startPosition byte
            // and return them. Simple as that!
            //
            //NOTE: we have to add an additional 32 bytes to account for the
            // 32 bytes specifying the length of the array at the beggining.
            let start := add(data, add(_startPosition, 0x20))
            return(start, 0x20)
        }
    }

    function lengthOf(uint256 _proposalID, uint256 _startPosition) internal constant returns (uint256) {
        bytes memory data = proposals[_proposalID].data;

        assembly {
            // make sure we don’t overstep array boundaries because in assembly
            // there’s no built-in boundary checks
            // We’re basically comparing _startPosition to the length of the array
            // (stored in the first 32 bytes) and subtracting the length of an uint
            switch lt(_startPosition, sub(mload(data), 32))
            case 0 { stop }

            // Let’s just load the 32 bytes following the _startPosition byte
            // and return them. Simple as that!
            //
            //NOTE: we have to add an additional 32 bytes to account for the
            // 32 bytes specifying the length of the array at the beggining.
            let start := add(data, add(_startPosition, 0x20))
            return(start, 0x20)
        }
    }

    function dataOf(uint256 _proposalID, uint256 _startPosition) internal constant returns (bytes) {
        bytes memory data = proposals[_proposalID].data;

        assembly {
            // make sure we don’t overstep array boundaries because in assembly
            // there’s no built-in boundary checks
            // We’re basically comparing _startPosition to the length of the array
            // (stored in the first 32 bytes) and subtracting the length of an uint
            switch lt(_startPosition, sub(mload(data), 32))
            case 0 { stop }

            // We have to add an additional 32 bytes to account for the
            // 32 bytes specifying the length of the array at the beggining.
            let start := add(_startPosition, 0x20)

            // Now we actually load the size of the inner tightly packed bytes
            // array of our calldata structure
            let bytesLength := mload(add(data, start))

            // add 32 bytes to start because we won’t need the length for what
            // we’re doing next :D
            start := add(start, 0x20)

            // Let’s just load the `bytesLength` bytes following the `start` byte
            // and return them. Simple as that!
            return(start, bytesLength)
        }
    }

    function signatureOf(uint256 _proposalID, uint256 _startPosition) internal constant returns (bytes4) {
        bytes memory data = proposals[_proposalID].data;

        assembly {
            // make sure we don’t overstep array boundaries because in assembly
            // there’s no built-in boundary checks
            // We’re basically comparing _startPosition to the length of the array
            // (stored in the first 32 bytes) and subtracting the length of an uint
            switch lt(_startPosition, sub(mload(data), 32))
            case 0 { stop }

            // We have to add an additional 32 bytes to account for the
            // 32 bytes specifying the length of the array at the beggining.
            let start := add(_startPosition, 0x20)

            // Now we actually load the size of the inner tightly packed bytes
            // array of our calldata structure
            let bytesLength := mload(add(data, start))

            // make sure we don’t overstep array boundaries again, this time for
            // the inner dynamic array. We’re checking if it is at least 4 bytes
            // (the size of a function ID) long
            switch lt(mload(add(data, start)), 4)
            case 0 { stop }

            // And finally we’re gonna return the first (existing!) 4 bytes of
            // the inner dynamic array
            return(start, 4)
        }
    }
}
