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

contract EvmStack {
    uint256[1024] _stack;
    uint256       _stackPointer; // offset of the invalid element on the very top of stack

    function push(uint256 value) {
        require(_stackPointer < _stack.length);
        _stack[_stackPointer++] = value;
    }

    function pop() returns (uint256) {
        require(_stackPointer > 0);
        return _stack[--_stackPointer];
    }

    function top() constant returns (uint256) {
        require(_stackPointer > 0);
        return _stack[_stackPointer - 1];
    }

    function isEmpty() constant returns (bool) {
        return _stackPointer > 0;
    }

    function size() constant returns (uint256) {
        return _stackPointer;
    }

    function capacity() constant returns (uint256) {
        return _stack.length;
    }

    function stackOffset(uint256 offset) constant returns (uint256) {
        // this should probably be a debugging only facility
        require(_stackPointer > 0 && // must have at least one item on the stack
                _stackPointer >= (offset + 1) && // and be out of neither the lower bound
                _stackPointer - (offset + 1) < _stack.length); // nor the upper bound of the stack
        return _stack[_stackPointer - (offset + 1)];
    }

    function swapTop(uint256 value) returns (uint256) {
        require(_stackPointer > 0); // must have at least one item on the stack to have a top to swap
        _stack[_stackPointer - 1] ^= value;
        value ^= _stack[_stackPointer - 1];
        _stack[_stackPointer - 1] ^= value;
        return value;
    }
}
