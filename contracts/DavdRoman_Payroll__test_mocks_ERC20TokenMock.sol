pragma solidity ^0.4.11;

import '../../contracts/Tokens/ERC20Token.sol';

contract ERC20TokenMock is ERC20Token {

	bool shouldSucceedTransfers = true;

    function ERC20TokenMock(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol)
		ERC20Token(_initialAmount, _tokenName, _decimalUnits, _tokenSymbol) {

	}

	function mock_setShouldSucceedTransfers(bool _shouldSucceedTransfers) {
		shouldSucceedTransfers = _shouldSucceedTransfers;
	}

    function transfer(address _to, uint256 _value) returns (bool success) {
		if (shouldSucceedTransfers) {
			return super.transfer(_to, _value);
		} else {
			return false;
		}
    }
}
