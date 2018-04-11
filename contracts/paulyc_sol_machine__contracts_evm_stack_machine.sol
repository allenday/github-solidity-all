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
import './constants.sol';

contract EthereumStackMachine is Constants {

    enum ExecutionStatus {
        PRE_EXECUTION,
        EXECUTING,
        HALTED
    }

    struct ExecutionEnvironment {
        address codeOwner;                  // I_a, the address of the account which owns the code that is executing
        address transactionOriginator;      // I_o, the sender address of the transaction that originated this execution.
        uint256 gasPrice;                   // I_p, the price of gas in the transaction that origi- nated this execution
        byte[]  inputData;                  // I_d, the byte array that is the input data to this execution; if the execution agent is a transaction, this would be the transaction data
        address executor;                   // I_s, the address of the account which caused the code to be executing; if the execution agent is a transaction, this would be the transaction sender
        uint256 valuePassedWithExecution;   // I_v, the value, in Wei, passed to this account as part of the same procedure as execution; if the execution agent is a transaction, this would be the transaction value.
        byte[]  machineCode;                // I_b, the byte array that is the machine code to be executed
        uint256 blockHeader;                // I_H, the block header of the present block
        uint256 callOrCreateDepth;          // I_e, the depth of the present message-call or contract-creation (i.e. the number of CALLs or CREATEs being executed at present)
    }

    struct SystemState {
        uint256[1024] stack;
        uint16 stackPointer;

        uint256[]  memory_;
        mapping(uint256 => uint256) storage_;

        uint256 gasAvailable;
        uint256 gasConsumed;
        uint256 programCounter;

        ExecutionStatus      status;
        ExecutionEnvironment environment;
    }

    function executeTransaction(ContractCreationTransaction transaction) {
        SystemState state;

        //bytes storage program = transaction.getProgram();
        bytes program;
        state.status = ExecutionStatus.EXECUTING;

        while (state.status != ExecutionStatus.HALTED && state.programCounter < program.length) {
            byte opCode = program[state.programCounter++];
            dispatchInstruction(opCode, state);
        }
    }

    function executeStop(SystemState state) internal {
        state.status = ExecutionStatus.HALTED;
        state.gasConsumed++;
    }

    function executeAdd(SystemState state) internal {
        require(state.stackPointer-- >= 2);
        state.stack[state.stackPointer - 1] += state.stack[state.stackPointer];
        state.gasConsumed++;
    }

    function executeMul(SystemState state) internal {
        require(state.stackPointer-- >= 2);
        state.stack[state.stackPointer - 1] *= state.stack[state.stackPointer];
        state.gasConsumed++;
    }

    function executeSub(SystemState state) internal {
        require(state.stackPointer-- >= 2);
        state.stack[state.stackPointer - 1] = state.stack[state.stackPointer] - state.stack[state.stackPointer - 1];
        state.gasConsumed++;
    }

    function executeDiv(SystemState state) internal {
        require(state.stackPointer-- >= 2);
        if (state.stack[state.stackPointer - 1] == 0) {
            // no op, leave 0 in result
        } else {
            state.stack[state.stackPointer - 1] = state.stack[state.stackPointer] / state.stack[state.stackPointer - 1];
        }
        state.gasConsumed++;
    }

    function executeSdiv(SystemState state) internal {
        require(state.stackPointer-- >= 2);
        if (state.stack[state.stackPointer - 1] == 0) {
            // no op, leave 0 in result
        } else if (state.stack[state.stackPointer] == 0x800000000000000000000000000000000000000000000000 &&
                state.stack[state.stackPointer - 1] == uint256(-1)) {
            // If you were wondering, 0x800000000000000000000000000000000000000000000000 is binary 2's complement for -2^255
            // and although -2^255 / -1 = 2^255 in normal math, in signed 256-bit 2's complement, it overflows,
            // so the actual result here is -2^255. Don't ask me, I don't make the rules, I just implement them
            state.stack[state.stackPointer - 1] = 0x800000000000000000000000000000000000000000000000;
        } else {
            state.stack[state.stackPointer - 1] = uint256(int256(state.stack[state.stackPointer]) / int256(state.stack[state.stackPointer - 1]));
        }
        state.gasConsumed++;
    }

    function executeMod(SystemState state) internal {
        require(state.stackPointer-- >= 2);
        if (state.stack[state.stackPointer - 1] == 0) {
            // no op, leave 0 in result
        } else {
            state.stack[state.stackPointer - 1] = state.stack[state.stackPointer] % state.stack[state.stackPointer - 1];
        }
        state.gasConsumed++;
    }

    function executeSmod(SystemState state) internal {
        require(state.stackPointer-- >= 2);
        if (state.stack[state.stackPointer - 1] == 0) {
            // no op, leave 0 in result
        } else {
            state.stack[state.stackPointer - 1] = uint256(int256(state.stack[state.stackPointer]) % int256(state.stack[state.stackPointer - 1]));
        }
        state.gasConsumed++;
    }

    function executeAddmod(SystemState state) internal {
        // stubbed no-op
    }

    function executeMulmod(SystemState state) internal {
        // stubbed no-op
    }

    function executeExp(SystemState state) internal {
        // stubbed no-op
    }

    function executeSignextend(SystemState state) internal {
        // stubbed no-op
    }

    function illegalOperation(SystemState state) internal {
        UnhandledException(state.programCounter);
        revert();
    }

    event TransactionComplete(Transaction);
    event UnhandledException(uint256 programCounter);

    function dispatchInstruction(byte OpCode,  SystemState state) internal {
        /*assembly {
            switch OpCode
            // Stop and Arithmetic Operations
            case 0x00 { call() } // OP_STOP
            case 0x01 { executeAdd(state) } // OP_ADD
            case 0x02 { executeMul(state) }
            default   { illegalOperation(state) }
        }*/
        if (OpCode == OP_STOP) {
            executeStop(state);
        } else {
            illegalOperation(state);
        }
    }

    /*
            // OP_SUB            = executeSub;
            // OP_DIV            = executeDiv;
            // OP_SDIV           = executeSdiv;
            // OP_MOD            = executeMod;
            // OP_SMOD           = executeSmod;
            // OP_ADDMOD         = executeAddmod;
            // OP_MULMOD         = executeMulmod;
            // OP_EXP            = executeExp;
            // OP_SIGNEXTEND     = executeSignextend;

            // Comparison and Bitwise Logic Operations
            // OP_LT
            // OP_GT
            // OP_SLT
            // OP_SGT
            // OP_EQ
            // OP_ISZERO
            // OP_AND
            // OP_OR
            // OP_XOR
            // OP_NOT
            // OP_BYTE

            // SHA3
            // OP_SHA3

            // Environmental Information
            // OP_ADDRESS
            // OP_BALANCE
            // OP_ORIGIN
            // OP_CALLER
            // OP_CALLVALUE
            // OP_CALLDATALOAD
            // OP_CALLDATASIZE
            // OP_CALLDATACOPY
            // OP_CODESIZE
            // OP_CODECOPY
            // OP_GASPRICE
            // OP_EXTCODESIZE
            // OP_EXTCODECOPY

            // Block Information
            // OP_BLOCKHASH
            // OP_COINBASE
            // OP_TIMESTAMP
            // OP_NUMBER
            // OP_DIFFICULTY
            // OP_GASLIMIT

            // Stack, Memory, Storage, and Flow Operations
            // OP_POP
            // OP_MLOAD
            // OP_MSTORE
            // OP_MSTORE8
            // OP_SLOAD
            // OP_SSTORE
            // OP_JUMP
            // OP_JUMPI
            // OP_PC
            // OP_MSIZE
            // OP_GAS
            // OP_JUMPDEST

            // Push Operations
            // OP_PUSH1
            // OP_PUSH2
            // OP_PUSH3
            // OP_PUSH4
            // OP_PUSH5
            // OP_PUSH6
            // OP_PUSH7
            // OP_PUSH8
            // OP_PUSH9
            // OP_PUSH10
            // OP_PUSH11
            // OP_PUSH12
            // OP_PUSH13
            // OP_PUSH14
            // OP_PUSH15
            // OP_PUSH16
            // OP_PUSH17
            // OP_PUSH18
            // OP_PUSH19
            // OP_PUSH20
            // OP_PUSH21
            // OP_PUSH22
            // OP_PUSH23
            // OP_PUSH24
            // OP_PUSH25
            // OP_PUSH26
            // OP_PUSH27
            // OP_PUSH28
            // OP_PUSH29
            // OP_PUSH30
            // OP_PUSH31
            // OP_PUSH32

            // Duplication Operations
            // OP_DUP1
            // OP_DUP2
            // OP_DUP3
            // OP_DUP4
            // OP_DUP5
            // OP_DUP6
            // OP_DUP7
            // OP_DUP8
            // OP_DUP9
            // OP_DUP10
            // OP_DUP11
            // OP_DUP12
            // OP_DUP13
            // OP_DUP14
            // OP_DUP15
            // OP_DUP16

            // Exchange Operations
            // OP_SWAP1
            // OP_SWAP2
            // OP_SWAP3
            // OP_SWAP4
            // OP_SWAP5
            // OP_SWAP6
            // OP_SWAP7
            // OP_SWAP8
            // OP_SWAP9
            // OP_SWAP10
            // OP_SWAP11
            // OP_SWAP12
            // OP_SWAP13
            // OP_SWAP14
            // OP_SWAP15
            // OP_SWAP16

            // Logging Operations
            // OP_LOG0
            // OP_LOG1
            // OP_LOG2
            // OP_LOG3
            // OP_LOG4

            // System Operations
            // OP_CREATE
            // OP_CALL
            // OP_CALLCODE
            // OP_RETURN
            // OP_DELEGATECALL

            // Halt Execution, Mark for Deletion
            // OP_SELFDESTRUCT **/
}
