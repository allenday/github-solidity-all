pragma solidity ^0.4.11;

import '../Tokens/ERC20.sol';
import './IExchange.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract USDExchange is Ownable, IExchange {
	using SafeMath for uint;

	address public exchangeRateOracle;
	address[] public availableTokens;
	mapping (address => uint) public exchangeRates; // 18 decimals

	function USDExchange(address usdExchangeRateOracle) {
		exchangeRateOracle = usdExchangeRateOracle;
	}

	function setExchangeRateOracle(address newOracle) onlyOwner {
		require(newOracle != 0x0);
		exchangeRateOracle = newOracle;
	}

	function exchange(address token, uint amount, uint rate) constant returns (uint) {
		if (amount == 0) return 0;
		require(token != 0x0);
		require(rate > 0);

		uint decimals = ERC20(token).decimals();
		require(decimals >= 0);
		require(decimals <= 18);
		
		return amount.mul(10**decimals).div(rate);
	}

	function getAvailableTokens() constant returns(address[]) {
		return availableTokens;
	}

	// Oracle-only

	modifier onlyOracle() {
		require(msg.sender == exchangeRateOracle);
		_;
	}

	function setExchangeRate(address token, uint exchangeRate) onlyOracle {
		require(token != 0x0);
		require(exchangeRate > 0);

		// add if new token
		if (exchangeRates[token] == 0) {
			availableTokens.push(token);
		}

		// set exchange rate
		exchangeRates[token] = exchangeRate;
	}
}
