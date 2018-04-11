/**
 *  Copyright (c) 2017 Paul Ciarlo
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

pragma solidity ^0.4.15;

import './logging.sol';

/**
A transaction (formally, T) is a single cryptographically-signed instruction constructed
by an actor externally to the scope of Ethereum. While it is assumed that the ultimate
external actor will be human in nature, software tools will be used in its construction
and dissemination1. There are two types of transactions: those which result in message
calls and those which result in the creation of new accounts with associated code (known
informally as ‘contract creation’)
*/
contract Transaction {
    struct AccumulatedSubstate {
        address[] selfDestructSet;
        Logging.LogEntry[] logSeries;
        uint256 refundBalance;
        uint256 gasConsumed;
    }

    struct Receipt {
       // SystemState postTransactionState;
        uint256 gasConsumed;
        Logging.LogEntry[] logSeries;
        bytes bloomFilter;
    }

    uint256 _nonce;     // A scalar value equal to the number of transactions sent by the sender; formally T_n
    uint256 _gasPrice;  // A scalar value equal to the number of Wei to be paid per unit of gas for all computation costs incurred as a result of the execution of this transaction; formally T_p
    uint256 _gasLimit;  // A scalar value equal to the maximum amount of gas that should be used in executing this transaction. This is paid up-front, before any computation is done and may not be increased later; formally T_g
    address _to;        // The 160-bit address of the message call’s recipient or, for a contract creation transaction, ∅, used here to denote the only member of B0 ; formally T_t
    uint256 _value;     // A scalar value equal to the number of Wei to be transferred to the message call’s recipient or, in the case of contract creation, as an endowment to the newly created account; formally T_v
    // Values corresponding to the signature of the transaction and used to determine the sender of the transaction; formally T_w, T_r and T_s
    uint8   _v;
    uint256 _r;
    uint256 _s;
    bytes   _initOrInput; // init code for contract creation, input data for message passing

    function Transaction(uint256 gasPrice, uint256 gasLimit, address to, uint256 value, uint8 v, uint256 r, uint256 s, bytes initOrInput) {
        _nonce = 0;
        _gasPrice = gasPrice;
        _gasLimit = gasLimit;
        _to = to;
        _value = value;
        _v = v;
        _r = r;
        _s = s;
        _initOrInput = initOrInput;
    }
    
    function verifyTransaction() constant returns (bool) {
        /**
        (1) The transaction is well-formed RLP, with no ad- ditional trailing bytes;
        (2) the transaction signature is valid;
        (3) the transaction nonce is valid (equivalent to the
        sender account’s current nonce);
        (4) the gas limit is no smaller than the intrinsic gas,
        g0, used by the transaction;
        (5) the sender account balance contains at least the
        cost, v0, required in up-front payment.
    */
    }

    function getInitOrInput() constant public returns (bytes) {
        return _initOrInput;
    }
}

contract ContractCreationTransaction is Transaction {

    // init: An unlimited size byte array specifying the EVM-code for the account initialisation proce- dure, formally T_i.
    function ContractCreationTransaction(bytes init, uint256 gasPrice, uint256 gasLimit, address to, uint256 value, uint8 v, uint256 r, uint256 s)
        Transaction(gasPrice, gasLimit, to, value, v, r, s, init) {
    }

    AccumulatedSubstate substate;
    function getProgram() constant public returns (bytes) {
        return getInitOrInput();
    }
}

contract MessageCallTransaction is Transaction {
    // init: An unlimited size byte array specifying the input data of the message call, formally T_d
    function MessageCallTransaction(bytes init, uint256 gasPrice, uint256 gasLimit, address to, uint256 value, uint8 v, uint256 r, uint256 s)
        Transaction(gasPrice, gasLimit, to, value, v, r, s, init) {
    }
}
