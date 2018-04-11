pragma solidity ^0.4.15;
import './AO.sol';
import './bancor_contracts/interfaces/IERC20Token.sol';

import './interfaces/IPriceDiscovery.sol';

/**
    PriceDiscovery.sol is a contract that dynamically tracks the exchange rates
    between the different currencies. The main functionality is providing a simplified
    facade to the BancorChanger backend, currently comprised of:
        - .exchangeRate()
 */
contract PriceDiscovery is IPriceDiscovery {
    IERC20Token fromToken; // token conversion source
    IERC20Token toToken;   // token conversion destination

    /**
        @dev constructor

        @param  _fromToken    Address of the token being converted from
        @param  _toToken      Address of the token being converted into

    */
    function PriceDiscovery(address _fromToken, address _toToken) {
        fromToken = IERC20Token(_fromToken);
        toToken = IERC20Token(_toToken);
    }

    /**
        @dev Returns the exchange rate of a single from token to how many toTokens that
        would create

    */
    function exchangeRate()
        public constant returns (uint)
    {
        // TODO: implement function
        return 1;
    }
}