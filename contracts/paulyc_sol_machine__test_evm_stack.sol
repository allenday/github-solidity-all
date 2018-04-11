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

import '../contracts/evm_stack.sol';
import './test_harness.sol';

contract TestEvmStack is TestHarness {
    EvmStack stackUnderTest;

    function TestEvmStack() TestHarness([testInit, testPush, testPop, testSwapTop]) {

    }

    function testInit() {
        stackUnderTest = new EvmStack();
        require(stackUnderTest.isEmpty());
        require(stackUnderTest.capacity() == 1024);
        require(stackUnderTest.size() == 0);
    }

    function testPush() {
        stackUnderTest = new EvmStack();
        stackUnderTest.push(1);
        require(!stackUnderTest.isEmpty());
        require(stackUnderTest.size() == 1);
        stackUnderTest.push(2);
        stackUnderTest.push(3);
        require(stackUnderTest.size() == 3);
        require(stackUnderTest.top() == 3);
        require(stackUnderTest.stackOffset(2) == 1);
        require(stackUnderTest.capacity() == 1024);
    }

    function testPop() {
        stackUnderTest = new EvmStack();
        stackUnderTest.push(1);
        stackUnderTest.push(2);
        stackUnderTest.push(3);
        require(stackUnderTest.pop() == 3);
        require(stackUnderTest.top() == 2);
        require(stackUnderTest.size() == 2);
        require(stackUnderTest.stackOffset(1) == 1);
        require(stackUnderTest.pop() == 2);
        require(stackUnderTest.pop() == 1);
        require(stackUnderTest.isEmpty());
        require(stackUnderTest.size() == 0);
        require(stackUnderTest.capacity() == 1024);
    }

    function testSwapTop() {
        stackUnderTest = new EvmStack();
        stackUnderTest.push(1);
        stackUnderTest.push(2);
        stackUnderTest.push(3);
        require(stackUnderTest.swapTop(4) == 3);
        require(stackUnderTest.top() == 4);
        require(stackUnderTest.size() == 3);
        require(stackUnderTest.pop() == 4);
        require(stackUnderTest.pop() == 2);
        require(stackUnderTest.pop() == 1);
        require(stackUnderTest.isEmpty());
    }
}