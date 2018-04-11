*/
pragma solidity ^0.4.8;

import "./Proxy.sol";
import "./base/Token.sol";
import "./base/SafeMath.sol";
// Error Codes
    uint8 constant ERROR_FILL_EXPIRED = 0;           // Order has already expired
    uint8 constant ERROR_FILL_NO_VALUE = 1;          // Order has already been fully filled or cancelled
    uint8 constant ERROR_FILL_TRUNCATION = 2;        // Rounding error too large
    uint8 constant ERROR_FILL_BALANCE_ALLOWANCE = 3; // Insufficient balance or allowance for token transfer
    uint8 constant ERROR_CANCEL_EXPIRED = 4;         // Order has already expired
    uint8 constant ERROR_CANCEL_NO_VALUE = 5;        // Order has already been fully filled or cancelled

    address public ZRX;
    address public PROXY;

    // Mappings of orderHash => amounts of valueT filled or cancelled.
    mapping (bytes32 => uint) public filled;
    mapping (bytes32 => uint) public cancelled;

    event LogFill(
        address indexed maker,
        address taker,
        address indexed feeRecipient,
        address tokenM,
        address tokenT,
        uint filledValueM,
        uint filledValueT,
        uint feeMPaid,
        uint feeTPaid,
        bytes32 indexed tokens,
        bytes32 orderHash
    );

    event LogCancel(
        address indexed maker,
        address indexed feeRecipient,
        address tokenM,
        address tokenT,
        uint cancelledValueM,
        uint cancelledValueT,
        bytes32 indexed tokens,
        bytes32 orderHash
    );

    event LogError(uint8 indexed errorId, bytes32 indexed orderHash);

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
        bytes32 orderHash;
    }

    function Exchange(address _zrx, address _proxy) {
        ZRX = _zrx;
        PROXY = _proxy;
    }

    /*
    * Core exchange functions
    */

    /// @dev Fills the input order.
    /// @param orderAddresses Array of order's maker, taker, tokenM, tokenT, and feeRecipient.
    /// @param orderValues Array of order's valueM, valueT, feeM, feeT, expiration, and salt.
    /// @param fillValueT Desired amount of tokenT to fill.
    /// @param shouldCheckTransfer Test if transfer will fail before attempting.
    /// @param v ECDSA signature parameter v.
    /// @param r CDSA signature parameters r.
    /// @param s CDSA signature parameters s.
    /// @return Total amount of tokenM filled in trade.
    function fill(
          address[5] orderAddresses,
          uint[6] orderValues,
          uint fillValueT,
          bool shouldCheckTransfer,
          uint8 v,
          bytes32 r,
          bytes32 s)
          returns (uint filledValueT)
    {
        Order memory order = Order({
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
            orderHash: getOrderHash(orderAddresses, orderValues)
        });

        assert(order.taker == address(0) || order.taker == msg.sender);

        if (block.timestamp >= order.expiration) {
            LogError(ERROR_FILL_EXPIRED, order.orderHash);
            return 0;
        }

        uint remainingValueT = safeSub(order.valueT, getUnavailableValueT(order.orderHash));
        filledValueT = min(fillValueT, remainingValueT);
        if (filledValueT == 0) {
            LogError(ERROR_FILL_NO_VALUE, order.orderHash);
            return 0;
        }

        if (isRoundingError(order.valueT, filledValueT, order.valueM)) {
            LogError(ERROR_FILL_TRUNCATION, order.orderHash);
            return 0;
        }

        if (shouldCheckTransfer && !isTransferable(order, filledValueT)) {
            LogError(ERROR_FILL_BALANCE_ALLOWANCE, order.orderHash);
            return 0;
        }

        assert(isValidSignature(
            order.maker,
            order.orderHash,
            v,
            r,
            s
        ));

        uint filledValueM = getPartialValue(order.valueT, filledValueT, order.valueM);
        uint feeMPaid;
        uint feeTPaid;
        filled[order.orderHash] = safeAdd(filled[order.orderHash], filledValueT);
        assert(transferViaProxy(
            order.tokenM,
            order.maker,
            msg.sender,
            filledValueM
        ));
        assert(transferViaProxy(
            order.tokenT,
            msg.sender,
            order.maker,
            filledValueT
        ));
        if (order.feeRecipient != address(0)) {
            if (order.feeM > 0) {
                feeMPaid = getPartialValue(order.valueT, filledValueT, order.feeM);
                assert(transferViaProxy(
                    ZRX,
                    order.maker,
                    order.feeRecipient,
                    feeMPaid
                ));
            }
            if (order.feeT > 0) {
                feeTPaid = getPartialValue(order.valueT, filledValueT, order.feeT);
                assert(transferViaProxy(
                    ZRX,
                    msg.sender,
                    order.feeRecipient,
                    feeTPaid
                ));
            }
        }

        LogFill(
            order.maker,
            msg.sender,
            order.feeRecipient,
            order.tokenM,
            order.tokenT,
            filledValueM,
            filledValueT,
            feeMPaid,
            feeTPaid,
            sha3(order.tokenM, order.tokenT),
            order.orderHash
        );
        return filledValueT;
    }

    /// @dev Cancels the input order.
    /// @param orderAddresses Array of order's maker, taker, tokenM, tokenT, and feeRecipient.
    /// @param orderValues Array of order's valueM, valueT, feeM, feeT, expiration, and salt.
    /// @param cancelValueT Desired amount of tokenT to cancel in order.
    /// @return Amount of tokenM cancelled.
    function cancel(
        address[5] orderAddresses,
        uint[6] orderValues,
        uint cancelValueT)
        returns (uint cancelledValueT)
    {
        Order memory order = Order({
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
            orderHash: getOrderHash(orderAddresses, orderValues)
        });

        assert(order.maker == msg.sender);

        if (block.timestamp >= order.expiration) {
            LogError(ERROR_CANCEL_EXPIRED, order.orderHash);
            return 0;
        }

        uint remainingValueT = safeSub(order.valueT, getUnavailableValueT(order.orderHash));
        cancelledValueT = min(cancelValueT, remainingValueT);
        if (cancelledValueT == 0) {
            LogError(ERROR_CANCEL_NO_VALUE, order.orderHash);
            return 0;
        }

        cancelled[order.orderHash] = safeAdd(cancelled[order.orderHash], cancelledValueT);

        LogCancel(
            order.maker,
            order.feeRecipient,
            order.tokenM,
            order.tokenT,
            getPartialValue(order.valueT, cancelledValueT, order.valueM),
            cancelledValueT,
            sha3(order.tokenM, order.tokenT),
            order.orderHash
        );
        return cancelledValueT;
    }

    /*
    * Wrapper functions
    */

    /// @dev Fills an order with specified parameters and ECDSA signature, throws if specified amount not filled entirely.
    /// @param orderAddresses Array of order's maker, taker, tokenM, tokenT, and feeRecipient.
    /// @param orderValues Array of order's valueM, valueT, feeM, feeT, expiration, and salt.
    /// @param fillValueT Desired amount of tokenT to fill.
    /// @param v ECDSA signature parameter v.
    /// @param r CDSA signature parameters r.
    /// @param s CDSA signature parameters s.
    /// @return Success of entire fillValueT being filled.
    function fillOrKill(
        address[5] orderAddresses,
        uint[6] orderValues,
        uint fillValueT,
        uint8 v,
        bytes32 r,
        bytes32 s)
        returns (bool success)
    {
        assert(fill(
            orderAddresses,
            orderValues,
            fillValueT,
            false,
            v,
            r,
            s
        ) == fillValueT);
        return true;
    }

    /// @dev Synchronously executes multiple fill orders in a single transaction.
    /// @param orderAddresses Array of address arrays containing individual order addresses.
    /// @param orderValues Array of uint arrays containing individual order values.
    /// @param fillValuesT Array of desired amounts of tokenT to fill in orders.
    /// @param shouldCheckTransfer Test if transfers will fail before attempting.
    /// @param v Array ECDSA signature v parameters.
    /// @param r Array of ECDSA signature r parameters.
    /// @param s Array of ECDSA signature s parameters.
    /// @return True if no fills throw.
    function batchFill(
        address[5][] orderAddresses,
        uint[6][] orderValues,
        uint[] fillValuesT,
        bool shouldCheckTransfer,
        uint8[] v,
        bytes32[] r,
        bytes32[] s)
        returns (bool success)
    {
        for (uint i = 0; i < orderAddresses.length; i++) {
            fill(
                orderAddresses[i],
                orderValues[i],
                fillValuesT[i],
                shouldCheckTransfer,
                v[i],
                r[i],
                s[i]
            );
        }
        return true;
    }

    /// @dev Synchronously executes multiple fillOrKill orders in a single transaction.
    /// @param orderAddresses Array of address arrays containing individual order addresses.
    /// @param orderValues Array of uint arrays containing individual order values.
    /// @param fillValuesT Array of desired amounts of tokenT to fill in orders.
    /// @param v Array ECDSA signature v parameters.
    /// @param r Array of ECDSA signature r parameters.
    /// @param s Array of ECDSA signature s parameters.
    /// @return Success of all orders being filled with respective fillValueT.
    function batchFillOrKill(
      address[5][] orderAddresses,
      uint[6][] orderValues,
      uint[] fillValuesT,
      uint8[] v,
      bytes32[] r,
      bytes32[] s)
        returns (bool success)
    {
        for (uint i = 0; i < orderAddresses.length; i++) {
            assert(fillOrKill(
                orderAddresses[i],
                orderValues[i],
                fillValuesT[i],
                v[i],
                r[i],
                s[i]
            ));
        }
        return true;
    }

    /// @dev Synchronously executes multiple fill orders in a single transaction until total fillValueT filled.
    /// @param orderAddresses Array of address arrays containing individual order addresses.
    /// @param orderValues Array of uint arrays containing individual order values.
    /// @param fillValueT Desired total amount of tokenT to fill in orders.
    /// @param shouldCheckTransfer Test if transfers will fail before attempting.
    /// @param v Array ECDSA signature v parameters.
    /// @param r Array of ECDSA signature r parameters.
    /// @param s Array of ECDSA signature s parameters.
    /// @return Total amount of fillValueT filled in orders.
    function fillUpTo(
        address[5][] orderAddresses,
        uint[6][] orderValues,
        uint fillValueT,
        bool shouldCheckTransfer,
        uint8[] v,
        bytes32[] r,
        bytes32[] s)
        returns (uint filledValueT)
    {
        filledValueT = 0;
        for (uint i = 0; i < orderAddresses.length; i++) {
            assert(orderAddresses[i][3] == orderAddresses[0][3]); // tokenT must be the same for each order
            filledValueT = safeAdd(filledValueT, fill(
                orderAddresses[i],
                orderValues[i],
                safeSub(fillValueT, filledValueT),
                shouldCheckTransfer,
                v[i],
                r[i],
                s[i]
            ));
            if (filledValueT == fillValueT) break;
        }
        return filledValueT;
    }

    /// @dev Synchronously cancels multiple orders in a single transaction.
    /// @param orderAddresses Array of address arrays containing individual order addresses.
    /// @param orderValues Array of uint arrays containing individual order values.
    /// @param cancelValuesT Array of desired amounts of tokenT to cancel in orders.
    /// @return Success if no cancels throw.
    function batchCancel(
        address[5][] orderAddresses,
        uint[6][] orderValues,
        uint[] cancelValuesT)
        returns (bool success)
    {
        for (uint i = 0; i < orderAddresses.length; i++) {
            cancel(
                orderAddresses[i],
                orderValues[i],
                cancelValuesT[i]
            );
        }
        return true;
    }

    /*
    * Constant public functions
    */

    /// @dev Calculates Keccak-256 hash of order with specified parameters.
    /// @param orderAddresses Array of order's maker, taker, tokenM, tokenT, and feeRecipient.
    /// @param orderValues Array of order's valueM, valueT, feeM, feeT, expiration, and salt.
    /// @return Keccak-256 hash of order.
    function getOrderHash(address[5] orderAddresses, uint[6] orderValues)
        constant
        returns (bytes32 orderHash)
    {
        return sha3(
            this,
            orderAddresses[0], // maker
            orderAddresses[1], // taker
            orderAddresses[2], // tokenM
            orderAddresses[3], // tokenT
            orderAddresses[4], // feeRecipient
            orderValues[0],    // valueM
            orderValues[1],    // valueT
            orderValues[2],    // feeM
            orderValues[3],    // feeT
            orderValues[4],    // expiration
            orderValues[5]     // salt
        );
    }

    /// @dev Verifies that an order signature is valid.
    /// @param signer address of signer.
    /// @param hash Signed Keccak-256 hash.
    /// @param v ECDSA signature parameter v.
    /// @param r ECDSA signature parameters r.
    /// @param s ECDSA signature parameters s.
    /// @return Validity of order signature.
    function isValidSignature(
        address signer,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s)
        constant
        returns (bool isValid)
    {
        return signer == ecrecover(
            sha3("\x19chainxSigned Message:\n32", hash),
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

    /// @dev Checks if rounding error > 0.1%.
    /// @param denominator Denominator
    /// @param numerator Numerator
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present
    function isRoundingError(uint denominator, uint numerator, uint target)
        constant
        returns (bool isError)
    {
        return (target < 10**3 && mulmod(target, numerator, denominator) != 0);
    }

    /// @dev Calculates partial value given a fillValue and a corresponding total value.
    /// @param value Amount of token specified in order.
    /// @param fillValue Amount of token to be filled.
    /// @param target Value to calculate partial.
    /// @return Partial value of target.
    function getPartialValue(uint value, uint fillValue, uint target)
        constant
        returns (uint partialValue)
    {
        return safeDiv(safeMul(fillValue, target), value);
    }

    /// @dev Calculates the sum of values already filled and cancelled for a given order.
    /// @param orderHash The Keccak-256 hash of the given order.
    /// @return Sum of values already filled and cancelled.
    function getUnavailableValueT(bytes32 orderHash)
        constant
        returns (uint unavailableValueT)
    {
        return safeAdd(filled[orderHash], cancelled[orderHash]);
    }


    /*
    * Internal functions
    */

    /// @dev Transfers a token using Proxy transferFrom function.
    /// @param token Address of token to transferFrom.
    /// @param from Address transfering token.
    /// @param to Address receiving token.
    /// @param value Amount of token to transfer.
    /// @return Success of token transfer.
    function transferViaProxy(
        address token,
        address from,
        address to,
        uint value)
        internal
        returns (bool success)
    {
        return Proxy(PROXY).transferFrom(token, from, to, value);
    }

    /// @dev Checks if any order transfers will fail.
    /// @param order Order struct of params that will be checked.
    /// @param fillValueT Desired amount of tokenT to fill.
    /// @return Predicted result of transfers.
    function isTransferable(Order order, uint fillValueT)
        internal
        constant
        returns (bool isTransferable)
    {
        address taker = msg.sender;
        uint fillValueM = getPartialValue(order.valueT, fillValueT, order.valueM);
        if (   getBalance(order.tokenM, order.maker) < fillValueM
            || getAllowance(order.tokenM, order.maker) < fillValueM
            || getBalance(order.tokenT, taker) < fillValueT
            || getAllowance(order.tokenT, taker) < fillValueT
        ) return false;
        if (order.feeRecipient != address(0)) {
            uint feeValueM = getPartialValue(order.valueT, fillValueT, order.feeM);
            uint feeValueT = getPartialValue(order.valueT, fillValueT, order.feeT);
            if (   getBalance(ZRX, order.maker) < feeValueM
                || getAllowance(ZRX, order.maker) < feeValueM
                || getBalance(ZRX, taker) < feeValueT
                || getAllowance(ZRX, taker) < feeValueT
            ) return false;
        }
        return true;
    }

    /// @dev Get token balance of an address.
    /// @param token Address of token.
    /// @param owner Address of owner.
    /// @return Token balance of owner.
    function getBalance(address token, address owner)
        internal
        constant
        returns (uint balance)
    {
        return Token(token).balanceOf(owner);
    }

    /// @dev Get allowance of token given to Proxy by an address.
    /// @param token Address of token.
    /// @param owner Address of owner.
    /// @return Allowance of token given to Proxy by owner.
    function getAllowance(address token, address owner)
        internal
        constant
        returns (uint allowance)
    {
        return Token(token).allowance(owner, PROXY);
    }
}
