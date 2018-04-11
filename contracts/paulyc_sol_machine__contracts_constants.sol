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

contract Constants {
    // Stop and Arithmetic Operations
    byte constant OP_STOP       = 0x00;
    byte constant OP_ADD        = 0x01;
    byte constant OP_MUL        = 0x02;
    byte constant OP_SUB        = 0x03;
    byte constant OP_DIV        = 0x04;
    byte constant OP_SDIV       = 0x05;
    byte constant OP_MOD        = 0x06;
    byte constant OP_SMOD       = 0x07;
    byte constant OP_ADDMOD     = 0x08;
    byte constant OP_MULMOD     = 0x09;
    byte constant OP_EXP        = 0x0a;
    byte constant OP_SIGNEXTEND = 0x0b;

    // Comparison and Bitwise Logic Operations
    byte constant OP_LT     = 0x10;
    byte constant OP_GT     = 0x11;
    byte constant OP_SLT    = 0x12;
    byte constant OP_SGT    = 0x13;
    byte constant OP_EQ     = 0x14;
    byte constant OP_ISZERO = 0x15;
    byte constant OP_AND    = 0x16;
    byte constant OP_OR     = 0x17;
    byte constant OP_XOR    = 0x18;
    byte constant OP_NOT    = 0x19;
    byte constant OP_BYTE   = 0x1a;

    // SHA3
    byte constant OP_SHA3 = 0x20;

    // Environmental Information
    byte constant OP_ADDRESS      = 0x30;
    byte constant OP_BALANCE      = 0x31;
    byte constant OP_ORIGIN       = 0x32;
    byte constant OP_CALLER       = 0x33;
    byte constant OP_CALLVALUE    = 0x34;
    byte constant OP_CALLDATALOAD = 0x35;
    byte constant OP_CALLDATASIZE = 0x36;
    byte constant OP_CALLDATACOPY = 0x37;
    byte constant OP_CODESIZE     = 0x38;
    byte constant OP_CODECOPY     = 0x39;
    byte constant OP_GASPRICE     = 0x3a;
    byte constant OP_EXTCODESIZE  = 0x3b;
    byte constant OP_EXTCODECOPY  = 0x3c;

    // Block Information
    byte constant OP_BLOCKHASH  = 0x50;
    byte constant OP_COINBASE   = 0x51;
    byte constant OP_TIMESTAMP  = 0x52;
    byte constant OP_NUMBER     = 0x53;
    byte constant OP_DIFFICULTY = 0x54;
    byte constant OP_GASLIMIT   = 0x55;

    // Stack, Memory, Storage, and Flow Operations
    byte constant OP_POP      = 0x50;
    byte constant OP_MLOAD    = 0x51;
    byte constant OP_MSTORE   = 0x52;
    byte constant OP_MSTORE8  = 0x53;
    byte constant OP_SLOAD    = 0x54;
    byte constant OP_SSTORE   = 0x55;
    byte constant OP_JUMP     = 0x56;
    byte constant OP_JUMPI    = 0x57;
    byte constant OP_PC       = 0x58;
    byte constant OP_MSIZE    = 0x59;
    byte constant OP_GAS      = 0x5a;
    byte constant OP_JUMPDEST = 0x5b;

    // Push Operations
    byte constant OP_PUSH1  = 0x60;
    byte constant OP_PUSH2  = 0x61;
    byte constant OP_PUSH3  = 0x62;
    byte constant OP_PUSH4  = 0x63;
    byte constant OP_PUSH5  = 0x64;
    byte constant OP_PUSH6  = 0x65;
    byte constant OP_PUSH7  = 0x66;
    byte constant OP_PUSH8  = 0x67;
    byte constant OP_PUSH9  = 0x68;
    byte constant OP_PUSH10 = 0x69;
    byte constant OP_PUSH11 = 0x6a;
    byte constant OP_PUSH12 = 0x6b;
    byte constant OP_PUSH13 = 0x6c;
    byte constant OP_PUSH14 = 0x6d;
    byte constant OP_PUSH15 = 0x6e;
    byte constant OP_PUSH16 = 0x6f;
    byte constant OP_PUSH17 = 0x70;
    byte constant OP_PUSH18 = 0x71;
    byte constant OP_PUSH19 = 0x72;
    byte constant OP_PUSH20 = 0x73;
    byte constant OP_PUSH21 = 0x74;
    byte constant OP_PUSH22 = 0x75;
    byte constant OP_PUSH23 = 0x76;
    byte constant OP_PUSH24 = 0x77;
    byte constant OP_PUSH25 = 0x78;
    byte constant OP_PUSH26 = 0x79;
    byte constant OP_PUSH27 = 0x7a;
    byte constant OP_PUSH28 = 0x7b;
    byte constant OP_PUSH29 = 0x7c;
    byte constant OP_PUSH30 = 0x7d;
    byte constant OP_PUSH31 = 0x7e;
    byte constant OP_PUSH32 = 0x7f;

    // Duplication Operations
    byte constant OP_DUP1  = 0x80;
    byte constant OP_DUP2  = 0x81;
    byte constant OP_DUP3  = 0x82;
    byte constant OP_DUP4  = 0x83;
    byte constant OP_DUP5  = 0x84;
    byte constant OP_DUP6  = 0x85;
    byte constant OP_DUP7  = 0x86;
    byte constant OP_DUP8  = 0x87;
    byte constant OP_DUP9  = 0x88;
    byte constant OP_DUP10 = 0x89;
    byte constant OP_DUP11 = 0x8a;
    byte constant OP_DUP12 = 0x8b;
    byte constant OP_DUP13 = 0x8c;
    byte constant OP_DUP14 = 0x8d;
    byte constant OP_DUP15 = 0x8e;
    byte constant OP_DUP16 = 0x8f;

    // Exchange Operations
    byte constant OP_SWAP1  = 0x90;
    byte constant OP_SWAP2  = 0x91;
    byte constant OP_SWAP3  = 0x92;
    byte constant OP_SWAP4  = 0x93;
    byte constant OP_SWAP5  = 0x94;
    byte constant OP_SWAP6  = 0x95;
    byte constant OP_SWAP7  = 0x96;
    byte constant OP_SWAP8  = 0x97;
    byte constant OP_SWAP9  = 0x98;
    byte constant OP_SWAP10 = 0x99;
    byte constant OP_SWAP11 = 0x9a;
    byte constant OP_SWAP12 = 0x9b;
    byte constant OP_SWAP13 = 0x9c;
    byte constant OP_SWAP14 = 0x9d;
    byte constant OP_SWAP15 = 0x9e;
    byte constant OP_SWAP16 = 0x9f;

    // Logging Operations
    byte constant OP_LOG0 = 0xa0;
    byte constant OP_LOG1 = 0xa1;
    byte constant OP_LOG2 = 0xa2;
    byte constant OP_LOG3 = 0xa3;
    byte constant OP_LOG4 = 0xa4;

    // System Operations
    byte constant OP_CREATE       = 0xf0;
    byte constant OP_CALL         = 0xf1;
    byte constant OP_CALLCODE     = 0xf2;
    byte constant OP_RETURN       = 0xf3;
    byte constant OP_DELEGATECALL = 0xf4;

    // Halt Execution, Mark for Deletion
    byte constant OP_SELFDESTRUCT = 0xff;
}