pragma solidity ^0.4.15;

import './interface/IERC20Token.sol';
import './SafeMath.sol';

/*  ERC Token Standard #20 Interface
    https://github.com/ethereum/EIPs/issues/20
*/

contract ERC20Token is IERC20Token {
    using SafeMath for uint256;

    uint256 public totalSupply;

    mapping (address => uint256) public balances;              /* 代币余额 */
    mapping (address => mapping (address => uint256)) allowed;   /* 查询余额 */

    // event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    // event Approval(address indexed _owner, address indexed _spender, uint256 _amount);

    /**************************************************************************
    函数名: transfer(address，uint256)
    功能  ：调用者给指定账户转代币。
    参数  ：
        _to (address)   - 接受代币的账户
        _amount(uint256) - 转移的数量
    返回  ：
        success (bool)  - 转账操作的结果
    **************************************************************************/
    function transfer(address _to, uint256 _amount)public returns (bool) {
        require(balances[msg.sender] >= _amount);    /* 判断余额充足 */
        require(_amount > 0 && _to != 0x0);

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**************************************************************************
    函数名: transferFrom(address,address,uint256)
    功能  ：调用者(被授权人)通过授权人给指定账户转代币。
    参数  ：
        _from(address)  - 授权人的账户
        _to (address)   - 接受代币的账户
        _amount(uint256) - 转移的数量
    返回  ：
        success (bool)  - 转账操作的结果
    **************************************************************************/
    function transferFrom(address _from, address _to, uint256 _amount) public
        returns (bool) {
        require(balances[_from] >= _amount);              /* 判断余额充足 */
        require(allowed[_from][msg.sender] >= _amount);   /* 判断授权额度充足 */
        require(_amount > 0 && _to != 0x0);

        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        Transfer(_from, _to, _amount);
        return true;
    }

    /**************************************************************************
    函数名: approve(address,uint256)
    功能  ：调用者(授权人)给指定账户(被授权人)一定数量的使用额度(代用)。
    注意：1. _amount为 0时，取消授权额度。
         2. 不能直接修改授权额度，要先把额度清0，再重新授权。
    参数  ：
        _spender (address) - 被授权人(实际消费人)
        _amount(uint256)  - 可以代替使用的数量
    返回  ：
        success (bool)  - 授权操作的结果
    **************************************************************************/
    function approve(address _spender, uint256 _amount)public returns (bool) {
        require(_spender != 0x0);
        require(balances[msg.sender] >= _amount);

        /* 不能直接改变授权额度 */
        if (_amount != 0 && allowed[msg.sender][_spender] > 0 ){
            return false;
        }
        allowed[msg.sender][_spender] = _amount;

        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**************************************************************************
    函数名: totalSupply
    功能  : 获取代币总量。
    返回  ：
        supply (uint256) - 代币总数量
    **************************************************************************/
    function totalSupply()
        public constant returns(uint256 supply) {
        return totalSupply;
    }

    /**************************************************************************
    函数名: balanceOf(address)
    功能  ：获得地址账户的余额
    参数  ：
        _owner (address) - 要查询的账户地址
    返回  ：
        balance (uint256) - 账户余额
    **************************************************************************/
    function balanceOf(address _owner)
        public constant returns (uint256) {
        return balances[_owner];
    }

    /**************************************************************************
    函数名: allowance(address，address)
    功能  : 获取授权额度。
    参数  ：
        _owner (address)  - 授权人地址
        _spender(address) - 花费者地址(被授权人)
    返回  ：
        remaining (uint256) - 授权剩余额度
    **************************************************************************/
    function allowance(address _owner, address _spender)
        public constant returns (uint256) {
        return allowed[_owner][_spender];
    }



}
