pragma solidity ^0.4.11;

import '../SITExchanger.sol';

// @dev SITExchangerMock mocks current block number

contract SITExchangerMock is SITExchanger {

    function SITExchangerMock(address _sit, address _msp, address _contribution)
        SITExchanger(_sit,  _msp, _contribution) {}

    function getBlockNumber() internal constant returns (uint) {
        return mock_blockNumber;
    }

    function setMockedBlockNumber(uint _b) public {
        mock_blockNumber = _b;
    }

    uint public mock_blockNumber = 1;
}
