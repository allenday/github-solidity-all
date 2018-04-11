pragma solidity ^0.4.15;
import './AO.sol';
import './bancor_contracts/EtherToken.sol';
import './PriceDiscovery.sol';

import './interfaces/IPriceDiscovery.sol';
import './interfaces/IKnownTokens.sol';
import './bancor_contracts/interfaces/ITokenChanger.sol';

/**
    KnownTokens.sol is a shared data store contract between the RewardDao
    and the user Balances. It allows for a central store for both
    contracts to call access from, and (TODO) opens an API to add
    more supported tokens to the Safecontract network.
 */
contract KnownTokens is IKnownTokens {
    EtherToken etherToken;  
    AO safeToken;
    ITokenChanger tokenChanger;

    //    EG. priceDiscovery[token1][token2].exchangeRate();
    mapping(address => mapping(address => IPriceDiscovery)) priceDiscoveryMap;

    // We add in etherToken and safeToken as defaults to the network. (TODO) In
    // the future we will use this contract to make it easy to add more supported
    // tokens to the Safecontract network.
    address[] public knownTokens;

    /**
        @dev constructor

        @param  _etherToken     Address of the ERC20 ETH wrapper distributor
        @param  _safeToken      Address of the AO token
        @param  _tokenChanger   Address of the token changer (i.e. Bancor changer)

    */
    function KnownTokens(address _etherToken, address _safeToken, address _tokenChanger) {
        addToken(_etherToken);
        addToken(_safeToken);
        tokenChanger = ITokenChanger(_tokenChanger);
    }

    /**
        @dev Given the address of two tokens, determines what the conversion is, i.e.
        how many of token1 are in a single token2

        @param  _fromToken   FROM token address (i.e. conversion source)
        @param  _toToken     TO   token address (i.e. conversion destination)

    */
    function recoverPrice(address _fromToken, address _toToken)
        public constant returns (uint)
    {
        //TODO: implement function
        assert(_fromToken != _toToken); // ensure not doing useless conversion to same token
        var res = priceDiscoveryMap[_fromToken][_toToken];
        return res.exchangeRate();
    }

    /**
        @dev constructor

        @param  _newTokenAddr      Address of the new token being added
    */
    function addToken(address _newTokenAddr)
        public
    {
        // TODO: implement additional features of the function
        for (uint i = 0; i < knownTokens.length; ++i) {
            var fromNewToken = new PriceDiscovery(_newTokenAddr, knownTokens[i]);
            priceDiscoveryMap[_newTokenAddr][knownTokens[i]] = fromNewToken;

            var toNewToken   = new PriceDiscovery(knownTokens[i], _newTokenAddr);
            priceDiscoveryMap[knownTokens[i]][_newTokenAddr] = toNewToken;
        }

        knownTokens.push(_newTokenAddr);
    }

    /**
        @dev Generic search function for finding an entry in address array.

        @param _token   Address of the token of interest (to see whether registered)
        @return  boolean indicating if the token was previously registered (true) or not (false)
    */
    function containsToken(address _token)
        public constant returns (bool)
    {
        for (uint i = 0; i < knownTokens.length; ++i) {
            if (_token == knownTokens[i]) {return true;}
        }
        return false;
    }
}