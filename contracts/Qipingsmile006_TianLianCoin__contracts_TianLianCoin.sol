
pragma solidity ^0.4.15;

import './ERC20Token.sol';
import './Destruction.sol';


// contract TianLianCoin is Ownable, ERC20Token {

contract TianLianCoin is Destruction, ERC20Token {
    string public constant name = "TiamLian Coin";
    string public constant symbol = "TLC";
    string public constant version = "2.1";
    uint256  public constant decimals = 18;

 
    /* 众筹时间也可以用时间代替，这是用块决定 */
    bool    public isFunding = false;
    uint256 public startFundingBlock = 0;
    uint256 public stopFundingBlock  = 0;

    /*  */
    uint256 public currentSupply = 0;            /* 准备出售的代币  */
    uint256 public tokenRaised = 0;              /* 已售出代币 */
    uint256 public tokenExchangeRate = 1000; /* 1000TLC = 1 ETH */

    /* 众筹存款账户地址 */
    // address public ethFundDeposit = 0xBbf91Cf4cf582600BEcBb63d5BdB8D969F21779C;
    // address public newContractAddr = 0x0;              /* 升级地址 */

    event OwnerShipChanged(address indexed _oldOwner, address indexed _newOwner);
    event Minting(address indexed _to, uint256 _amount);
    event Burn(address indexed _from, uint256 _amount);
    event IssueToken(address indexed _to, uint256 _amount);
    event IncreaseSupply(uint256 _amount);
    event DecreaseSupply(uint256 _amount);

    /**************************************************************************
    函数名: TianLianCoin()
    功能  : 构造函数
    参数  ：  Null
    返回  ：  Null
    **************************************************************************/
    function TianLianCoin(uint256 _totalSupply, uint256 _currentSupply) {

        /*currentSupply = 100000000000; //11个0 ，1/10的代币*/
        // totalSupply = _totalSupply.mul(10 ** decimals);

        totalSupply = __toDecimals(_totalSupply);
        currentSupply = __toDecimals(_currentSupply);

        // currentSupply = _currentSupply.mul(10 ** decimals);
        require(currentSupply < totalSupply);
        // balances[ethFundDeposit] = totalSupply.sub(currentSupply);
        balances[owner] = totalSupply.sub(currentSupply);

    }


    /**************************************************************************
    函数名: mint(address，uint256)
    功能  : 挖矿生成代币给指定用户。
    参数  ：
        _owner (address)  - 接受者地址
        _value(uint256) - 代币的数量
    返回  ：
        success (bool) - 挖矿的结果
    思考 :
        这个函数是否赋予拥有者太大的权力？
    **************************************************************************/
    function mint(address _owner, uint256 _value) onlyOwner
        returns (bool){
        uint256 value = __toDecimals(_value);
        require(_owner != 0x0 && value > 0);

        balances[_owner] = balances[_owner].add(value);
        totalSupply = totalSupply.add(value);

        Minting(_owner, value);
        return true;
    }

    /**************************************************************************
    函数名: burn(uint256)
    功能  : 账户销毁自己一定数量代币。
    参数  ：
        _value(uint256) - 代币的数量
    返回  ：
        success (bool) - 销毁操作结果
    **************************************************************************/
    function burn(uint256 _value)
        returns (bool){
        uint256 value = __toDecimals(_value); 
        require(balances[msg.sender] >= value);
        require(value > 0);

        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);

        Burn(msg.sender, value);
        return true;
    }


    /**************************************************************************
    函数名: startFunding(uint256, uint256)
    功能  : 开始众筹
    参数  ：
        _fundingStartBlock (uint256)  - 众筹开始的块。
        _fundingStartBlock (uint256)  - 众筹结束的块。
    返回  ：
        success (bool) - 开启众筹操作的结果
    **************************************************************************/
    function startFunding(uint256 _fundingStartBlock, uint256 _fundingStopBlock)
        onlyOwner returns(bool){
        require(!isFunding);
        require(_fundingStartBlock < _fundingStopBlock);
        require(block.number < _fundingStartBlock);

        startFundingBlock = _fundingStartBlock;
        stopFundingBlock = _fundingStopBlock;
        isFunding = true;

        return true;
    }

    /**************************************************************************
    函数名: stopFunding
    功能  : 终止众筹
    参数  ：Null
    返回  ：
        success (bool) - 终止众筹操作的结果
    **************************************************************************/
    function stopFunding() onlyOwner external returns(bool){
        require(isFunding);
        isFunding = false;
        return true;
    }

    /**************************************************************************
    函数名: setTokenExchangeRate(uint256)
    功能  : 修改兑换比例
    参数  ： _newRate(uint256) - 新的兑换比例
    返回  ： Null
    **************************************************************************/
    function setTokenExchangeRate(uint256 _newRate) onlyOwner external {
        require(_newRate > 0 && _newRate != tokenExchangeRate);
        tokenExchangeRate = _newRate;
    }

    /**************************************************************************
    函数名: increaseSupply(uint256)
    功能  : 增加货币的供给量。
    参数  ：
        _value (uint256)  - 增加出售的代币数量
    返回  ：null
    **************************************************************************/
    function increaseSupply(uint256 _value) onlyOwner external{
        uint256 value = __toDecimals(_value); 
        require(value > 0);
        require(balances[msg.sender] > value);
        require(value + currentSupply < totalSupply);

        /* 众筹者将从个人账户把代币转移到正在出售的货币中 */
        balances[msg.sender] = balances[msg.sender].sub(value);
        currentSupply = currentSupply.add(value);

        IncreaseSupply(value);
    }

    /**************************************************************************
    函数名: decreaseSupply(uint256)
    功能  : 减少货币的供给量。
    参数  ：
        _value (uint256)  - 减少出售的代币数量
    返回  ：null
    **************************************************************************/
    function decreaseSupply(uint256 _value) onlyOwner external{
        uint256 value = __toDecimals(_value); 
        require(value > 0);
        require(currentSupply - value > tokenRaised);/* 供货量不能少于已售数量*/

        //把减少的出售的货币存入众筹者的个人账户
        balances[msg.sender] = balances[msg.sender].add(value);
        currentSupply = currentSupply.sub(value);           /* 减少供给量 */

        DecreaseSupply(value);
    }


    /**************************************************************************
    函数名: migrate(uint256)
    功能  : 代币升级迁移
    参数  ：
        _value (uint256)  - 减少出售的代币数量
    返回  ：null
    **************************************************************************/
    // function migrate(){

    // }


    /**************************************************************************
    函数名: setMigrateContract(address)
    功能  : 设置地址的迁移地址。
    参数  ：
        _value (uint256)  - 减少出售的代币数量
    返回  ：null
    **************************************************************************/
    // function setMigrateContract(address _newContactAddr)onlyOwner{
    //     require(_newContactAddr != 0x0);
    //     require(_newContactAddr != newContractAddr);

    //     newContractAddr = _newContactAddr;
    // }


    /**************************************************************************
     功能： 用于在众筹期间，合约接受以太币，
     **************************************************************************/
    function () payable{
        require(isFunding);
        require(msg.value > 0);

        require(block.number > startFundingBlock);
        require(block.number < stopFundingBlock);

        uint256 tokens = msg.value.mul(tokenExchangeRate);
        require(tokens + tokenRaised < currentSupply); /* 检查一下货币供应 */

        tokenRaised = tokenRaised.add(tokens);
        balances[msg.sender] = balances[msg.sender].add(tokens);

        IssueToken(msg.sender, tokens);

    }

    /**************************************************************************
    函数名: kill
    功能  : 调用析构函数，摧毁合约，把剩余的以太币发给合同拥有者。
    **************************************************************************/
    // function kill() onlyOwner {
    //     suicide(owner);
    // }

    function __formatDecimals(uint256 _value) internal returns (uint256 ) {
        uint256 value = _value.div(10 ** decimals);
        return value;
    }

    function __toDecimals(uint256 _value) internal returns (uint256 ) {
        uint256 value = _value.mul(10 ** decimals);
        return value;
    }
}
