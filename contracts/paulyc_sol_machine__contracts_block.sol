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

import './transaction.sol';

contract Block {
    struct Header {
        uint256 parentHash;    // The Keccak 256-bit hash of the par- ent block’s header, in its entirety; formally Hp. ommersHash: The Keccak 256-bit hash of the om-mers list portion of this block; formally Ho. beneficiary: The 160-bit address to which all fees collected from the successful mining of this blockbe transferred; formally H_c.
        uint256 stateRoot;     // The Keccak 256-bit hash of the root node of the state trie, after all transactions are executed and finalisations applied; formally Hr. transactionsRoot: TheKeccak256-bithashofthe root node of the trie structure populated with each transaction in the transactions list portionof the block; formally H_t.
        uint256 receiptsRoot;  // The Keccak 256-bit hash of the rootnode of the trie structure populated with the re- ceipts of each transaction in the transactions list portion of the block; formally H_e.
        uint256 logsBloom;     // The Bloom filter composed from in- dexable information (logger address and log top- ics) contained in each log entry from the receipt of each transaction in the transactions list; formally H_b.
        uint256 difficulty;    // A scalar value corresponding to the dif- ficulty level of this block. This can be calculated from the previous block’s difficulty level and the timestamp; formally H_d.
        uint256 number;        // A scalar value equal to the number of an- cestor blocks. The genesis block has a number of zero; formally H_i.
        uint256 gasLimit;      // A scalar value equal to the current limit of gas expenditure per block; formally H_l.
        uint256 gasUsed;       // A scalar value equal to the total gas used in transactions in this block; formally H_g.
        uint256 timestamp;     // A scalar value equal to the reasonable output of Unix’s time() at this block’s inception; formally H_s.
        bytes32 extraData;     // An arbitrary byte array containing data relevant to this block. This must be 32 bytes or fewer; formally H_x.
        uint256 mixHash;       // A 256-bit hash which proves combined with the nonce that a sufficient amount of compu- tation has been carried out on this block; formally H_m.
        uint64  nonce;         // A 64-bit hash which proves combined with the mix-hash that a sufficient amount of compu- tation has been carried out on this block; formally H_n.
    }

    Header _blockHeader;
    Header[] _ommerBlockHeaders;
    Transaction[] _transactions;

    function Block(Header header, Header[] ommerBlockHeaders, Transaction[] transactions) internal {
        _blockHeader = header;
        _ommerBlockHeaders = ommerBlockHeaders;
        _transactions = transactions;
    }

    function verify() constant {
    //
    }

    function finalize() {
        //(1) Validate (or, if mining, determine) ommers;
        //(2) validate (or, if mining, determine) transactions;
        //(3) apply rewards;
        //(4) verify (or, if mining, compute a valid) state and nonce.
    }
}
