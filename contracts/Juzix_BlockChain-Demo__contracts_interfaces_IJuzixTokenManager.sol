pragma solidity ^0.4.2;

contract IJuzixTokenManager {

   
    /// @dev 转账
    /// @param _param 零知识证明信息
    /// @param _to 接收者地址
    function transferPaillier(string _param,address _to) returns (bool);

    /// @dev 账户余额查询
    /// @param _owner 待查询账户地址
    /// @return _balance 当前账户的余额（加密数据）
    function balanceOfPaillier(address _owner) constant returns (string _balance) ;

    /// @dev 返回发行总量
    /// @return 总发行量
    function totalSupplyPaillier() constant returns (string _supply) ;

    /// @dev 授权指定用户代付金额
    function approvePaillier(address _spender, string _value) returns (bool) ;

    /// @dev 授权代付额度查询
    function allowancePaillier(address _owner, address _spender) constant returns (string remaining) ;

    /// @dev 查询转账记录
    function pageByAccount(address _account, uint _tranferType,uint _pageNum, uint _pageSize) constant public returns(string _json) ;

    /// @dev 认筹
    function buyFrom(string _params,address _to) public returns(uint);

    /// @dev 管理员用户判断
    function isAdmin() constant public returns(string _json);

    /// @dev 获取用户公钥
    function getPubkey(address _address) constant public returns(string _pubKey);

    /// @dev 设置流通股数
    function setCirculationShares(string _circulationShares) returns(bool);

    /// @dev 设置公钥
    function setPubkey(string _pubKey) returns (uint);
}