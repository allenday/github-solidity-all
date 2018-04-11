/**
* @file LibStack.sol
* @author liaoyan
* @time 2017-07-01
* @desc The defination of LibExtfuncs library.
*       All functions in this library are extension functions,
*       call eth functionalities through assembler commands.
*
* @funcs
*       stackPush(string _data) internal constant returns(bool _ret)
*       stackPop() internal constant returns(string _ret)
*       stackTop() internal constant returns(string _ret)
*       stackSize() internal constant returns(uint _ret)
*       stackClear() internal constant returns(uint _ret)
*       append(string _data) internal constant returns(bool _ret)
*       appendKeyValue(string _key, string _val) internal constant returns (bool _ret)
*       appendKeyValue(string _key, uint _val) internal constant returns (bool _ret)
*       appendKeyValue(string _key, int _val) internal constant returns (bool _ret)
*       appendKeyValue(string _key, address _val) internal constant returns (bool _ret)
*
* @usage
*       1) import "LibStack.sol";
*/

pragma solidity ^0.4.2;

import "../utillib/LibInt.sol";
import "../utillib/LibString.sol";

library LibStack {
    using LibInt for *;
    using LibString for *;

    function push(string _data) internal constant returns(bool _ret) {
        string memory arg = "[69d98d6a04c41b4605aacb7bd2f74bee][09StackPush]";
        arg = arg.concat(_data);

        uint argptr;
        uint arglen = bytes(arg).length;

        bytes32 b32;

        assembly {
            argptr := add(arg, 0x20)
            b32 := sha3(argptr, arglen)
        }

        if (uint(b32) != 0)
            return true;
        else
            return false;
    }

    function pop() internal constant returns(string _ret) {
        uint i = 0;
        uint stack_size = size();
        while (true) {
            string memory arg = "[69d98d6a04c41b4605aacb7bd2f74bee][08StackPop]";
            arg = arg.concat(uint(i*32).toString(), "|$%&@*^#!|", uint(32).toString());

            uint argptr;
            uint arglen = bytes(arg).length;

            bytes32 b32;
            assembly {
                argptr := add(arg, 0x20)
                b32 := sha3(argptr, arglen)
            }

            string memory r = uint(b32).recoveryToString();
            _ret = _ret.concat(r);
            if (bytes(r).length < 32 ||  stack_size != size())
                break;

            ++i;
        }
    }

    function top() internal constant returns(string _ret) {
        uint i = 0;
        while (true) {
            string memory arg = "[69d98d6a04c41b4605aacb7bd2f74bee][08StackTop]";
            arg = arg.concat(uint(i*32).toString(), "|$%&@*^#!|", uint(32).toString());

            uint argptr;
            uint arglen = bytes(arg).length;

            bytes32 b32;
            assembly {
                argptr := add(arg, 0x20)
                b32 := sha3(argptr, arglen)
            }

            string memory r = uint(b32).recoveryToString();
            _ret = _ret.concat(r);
            if (bytes(r).length < 32)
                break;

            ++i;
        }
    }

    function size() internal constant returns(uint _ret) {
        string memory arg = "[69d98d6a04c41b4605aacb7bd2f74bee][09StackSize]";
        arg = arg.concat(""); //don't delete this line

        uint argptr;
        uint arglen = bytes(arg).length;

        bytes32 b32;

        assembly {
            argptr := add(arg, 0x20)
            b32 := sha3(argptr, arglen)
        }

        return uint(b32);
    }
    
    function clear() internal constant returns(uint _ret) {
        string memory arg = "[69d98d6a04c41b4605aacb7bd2f74bee][10StackClear]";
        arg = arg.concat(""); //don't delete this line

        uint argptr;
        uint arglen = bytes(arg).length;

        bytes32 b32;

        assembly {
            argptr := add(arg, 0x20)
            b32 := sha3(argptr, arglen)
        }

        return uint(b32);
    }

    function append(string _data) internal constant returns(bool _ret) {
        string memory arg = "[69d98d6a04c41b4605aacb7bd2f74bee][11StackAppend]";
        arg = arg.concat(_data);

        uint argptr;
        uint arglen = bytes(arg).length;

        bytes32 b32;

        assembly {
            argptr := add(arg, 0x20)
            b32 := sha3(argptr, arglen)
        }

        if (uint(b32) != 0)
            return true;
        else
            return false;
    }

    function appendKeyValue(string _key, string _val) internal constant returns (bool _ret) {
        string memory arg = "[69d98d6a04c41b4605aacb7bd2f74bee][19StackAppendKeyValue]";
        arg = arg.concat(_key, "|$%&@*^#!|", _val);

        uint argptr;
        uint arglen = bytes(arg).length;

        bytes32 b32;

        assembly {
            argptr := add(arg, 0x20)
            b32 := sha3(argptr, arglen)
        }

        if (uint(b32) != 0)
            return true;
        else
            return false;
    }

    function appendKeyValue(string _key, uint _val) internal constant returns (bool _ret) {
        return appendKeyValue(_key, _val.toString());
    }

    function appendKeyValue(string _key, int _val) internal constant returns (bool _ret) {
        return appendKeyValue(_key, _val.toString());
    }

    function appendKeyValue(string _key, address _val) internal constant returns (bool _ret) {
        return appendKeyValue(_key, uint(_val).toAddrString());
    }
}
