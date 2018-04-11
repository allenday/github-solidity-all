pragma solidity ^0.4.15;
/*
 * 带有安全检查的数学运算，错误会抛出异常。
 */
library SafeMath {
    /* 加法 */
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a );           /* 检查溢出 */
        return c;
    }

    /* 减法 */
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(a >= b);           /* 保证结果为非负数 */
        return (a - b);
    }

    /* 乘法 */
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);  /* 不为零情况下，用除法验证结果，*/
        return c;
    }

    /* 除法 */
    // 注意：
    //    1.不需要判断被除数为0，solidity会自动报错
    //    2.不需要考虑 (a == b * c + a % b)，solidify中uint能存放小数
    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }
}
