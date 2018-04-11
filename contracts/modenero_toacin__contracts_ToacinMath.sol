pragma solidity ^0.4.11;


/**
 * Copyright (c) 2017 ICO Villa MDAO.
 * Released under the MIT License.
 *
 * Toacin Math Library
 * Version 17.7.1
 * 
 * @title ToacinMath
 *
 * @author ICO Villa (support@icovilla.com)
 *
 * @notice Mathematical operations with safety checks to prevent overflows.
 *
 * @dev Critical functions to prevent bugs like number overflows and 
 *      miscalculations.
 *
 *      Suggested usage: `using ToacinMath for uint;`
 *                       `uint integer_C = integer_A.add(integer_B);`
 */
library ToacinMath {
    
    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;

        assert(c >= a);

        return c;
    }

    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        
        return a - b;
    }

    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;

        assert(a == 0 || c / a == b);
        
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        uint c = a / b;
        
        return c;
    }

    function max(uint a, uint b) internal constant returns (uint) {
        return a >= b ? a : b;
    }

    function min(uint a, uint b) internal constant returns (uint) {
        return a < b ? a : b;
    }
}
