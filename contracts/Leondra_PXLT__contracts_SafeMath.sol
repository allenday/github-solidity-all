pragma solidity ^0.4.15;

/**
 * @title Safe math operations that throw error on overflow.
 *
 * Credit: Taking ideas from FirstBlood token
 */
library SafeMath {

    /** 
     * @dev Safely add two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x+y.
     */
    function add(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    /** 
     * @dev Safely substract two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x-y.
     */
    function sub(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    /** 
     * @dev Safely multiply two numbers.
     *
     * @param x First operant.
     * @param y Second operant.
     * @return The result of x*y.
     */
    function mul(uint256 x, uint256 y)
    internal constant
    returns(uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z/x == y));
        return z;
    }
}
