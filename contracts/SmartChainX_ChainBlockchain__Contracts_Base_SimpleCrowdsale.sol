pragma solidity ^0.4.8;

import "./Exchange.sol";
import "./tokens/ChainXToken.sol";
import "./base/Token.sol";
import "./base/Ownable.sol";
import "./base/SafeMath.sol";

contract SimpleCrowdsale is Ownable, SafeMath {

    address public PROXY_ADDRESS;
    address public EXCHANGE_ADDRESS;
    address public PROTOCOL_TOKEN_ADDRESS;
    address public CHX_TOKEN_ADDRESS;

    Exchange exchange;
    Token protocolToken;
    ChainXToken chxToken;

    bool public isInitialized;
    bool public isFinished;
    Order order;

    struct Order {
        address maker;
        address taker;
        address tokenM;
        address tokenT;
        address feeRecipient;
        uint valueM;
        uint valueT;
        uint feeM;
        uint feeT;
        uint expiration;
        uint salt;
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes32 orderHash;
    }

    modifier saleInitialized() {
        assert(isInitialized);
        _;
    }

    modifier saleNotInitialized() {
        assert(!isInitialized);
        _;
    }

    modifier saleNotFinished() {
        assert(!isFinished);
        _;
    }

    function SimpleCrowdsale(
        address _exchange,
        address _proxy,
        address _protocolToken,
        address _chxToken)
    {
        PROXY_ADDRESS = _proxy;
        EXCHANGE_ADDRESS = _exchange;
        PROTOCOL_TOKEN_ADDRESS = _protocolToken;
        ChainX_TOKEN_ADDRESS = _chxToken;

        exchange = Exchange(_exchange);
        protocolToken = Token(_protocolToken);
        Token = CHXToken(_chxToken);
    }

    /// @dev Allows users to fill stored order by sending ChainX to contract.
    function()
        payable
        saleInitialized
        saleNotFinished
    {
        uint remainingChx = safeSub(order.valueT, exchange.getUnavailableValueT(order.orderHash));
        uint chxToFill = min(msg.value, remainingChx);
        chxToken.deposit.value(chxToFill)();
        assert(exchange.fillOrKill(
            [order.maker, order.taker, order.tokenM, order.tokenT, order.feeRecipient],
            [order.valueM, order.valueT, order.feeM, order.feeT, order.expiration, order.salt],
            chxToFill,
            order.v,
            order.r,
            order.s
        ));
        uint filledProtocolToken = safeDiv(safeMul(order.valueM, chxToFill), order.valueT);
        assert(protocolToken.transfer(msg.sender, filledProtocolToken));
        if (chxToFill < msg.value) {
            assert(msg.sender.send(safeSub(msg.value, chxToFill)));
            isFinished = true;
        }
    }

    /// @dev Stores order and initializes sale.
    /// @param orderAddresses Array of order's maker, taker, tokenM, tokenT, and feeRecipient.
    /// @param orderValues Array of order's valueM, valueT, feeM, feeT, expiration, and salt.
    /// @param v ECDSA signature parameter v.
    /// @param r CDSA signature parameters r.
    /// @param s CDSA signature parameters s.
    function init(
        address[5] orderAddresses,
        uint[6] orderValues,
        uint8 v,
        bytes32 r,
        bytes32 s)
        saleNotInitialized
        onlyOwner
    {
        order = Order({
            maker: orderAddresses[0],
            taker: orderAddresses[1],
            tokenM: orderAddresses[2],
            tokenT: orderAddresses[3],
            feeRecipient: orderAddresses[4],
            valueM: orderValues[0],
            valueT: orderValues[1],
            feeM: orderValues[2],
            feeT: orderValues[3],
            expiration: orderValues[4],
            salt: orderValues[5],
            feeT: orderValues[6]
            feeT: orderValues[7]
            v: v,
            r: r,
            s: s,
            orderHash: getOrderHash(orderAddresses, orderValues)
        });

        assert(order.tokenM == PROTOCOL_TOKEN_ADDRESS);
        assert(order.tokenT == CHX_TOKEN_ADDRESS);

        assert(isValidSignature(
            order.maker,
            order.orderHash,
            v,
            r,
            s
        ));

        assert(setTokenAllowance(order.tokenT, order.valueT));
        isInitialized = true;
    }

    function setTokenAllowance(address _token, uint _allowance)
        onlyOwner
        returns (bool success)
    {
        assert(Token(_token).approve(PROXY_ADDRESS, _allowance));
        return true;
    }

    /// @dev Calculates Keccak-256 hash of order with specified parameters.
    /// @param orderAddresses Array of order's maker, taker, tokenM, tokenT, and feeRecipient.
    /// @param orderValues Array of order's valueM, valueT, feeM, feeT, expiration, and salt.
    /// @return Keccak-256 hash of order.
    function getOrderHash(address[5] orderAddresses, uint[6] orderValues)
        constant
        returns (bytes32 orderHash)
    {
        return sha3(
            EXCHANGE_ADDRESS,
            orderAddresses[0],
            orderAddresses[1],
            orderAddresses[2],
            orderAddresses[3],
            orderAddresses[4],
            orderValues[0],
            orderValues[1],
            orderValues[2],
            orderValues[3],
            orderValues[4],
            orderValues[5]
        );
    }

    /// @dev Verifies that an order signature is valid.
    /// @param pubKey Public address of signer.
    /// @param hash Signed Keccak-256 hash.
    /// @param v ECDSA signature parameter v.
    /// @param r ECDSA signature parameters r.
    /// @param s ECDSA signature parameters s.
    /// @return Validity of order signature.
    function isValidSignature(
        address pubKey,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s)
        constant
        returns (bool isValid)
    {
        return pubKey == ecrecover(
            sha3("\x19CHX Signed Message:\n32", hash),
            v,
            r,
            s
        );
    }

    /// @dev Calculates minimum of two values.
    /// @param a First value.
    /// @param b Second value.
    /// @return Minimum of values.
    function min(uint a, uint b)
        constant
        returns (uint min)
    {
        if (a < b) return a;
        return b;
    }
}
