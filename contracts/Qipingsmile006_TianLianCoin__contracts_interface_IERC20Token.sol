pragma solidity ^0.4.15;

/* ERC20 Standard Token interface */
contract IERC20Token {
    
    /* 调用者发送给账户(_to)数量为_value的代币 */
    function transfer(address to, uint256 value)public returns (bool success);
    /* _spender调用，_from发送给_to数量为_value的代币 */
    function transferFrom(address from, address to, uint256 value)public returns (bool success);
    /* 调用者授权_spender用户使用数量为_value的代币，如：第三方支付 */
    function approve(address spender, uint256 value)public returns (bool success);
    

    /* 整个数字货币的总量 */
    function totalSupply()public constant returns(uint256 supply);
    /* 得到传入地址的账户余额 */
    function balanceOf(address who)public constant returns (uint256 balance);
    /* 得到用户_owner 授权给 _soender 使用的代币剩余额度 */
    function allowance(address owner, address spender)public constant returns (uint256 value);


    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
    
}
