pragma solidity ^0.4.2;

import "./sysbase/OwnerNamed.sol";
import "./token/StandardToken.sol";
import "./interfaces/IJuzixTokenManager.sol";
import "./library/LibTokenPailler.sol";
import "./library/LibTokenRecord.sol";
import "./utillib/LibPaillier.sol";
import "./nizk/LibNIZK.sol";
import "./nizk/LibNizkParam.sol";

contract JuzixTokenManager is OwnerNamed, StandardToken, IJuzixTokenManager {

    using LibTokenPailler for *;
    using LibTokenRecord for *;
    using LibPaillier for *;
    using LibString for *;
    using LibInt for *;
    using LibNIZK for *;
    using LibNizkParam for *;

    string public constant name = "JuzixToken";
    string public constant symbol = "JNT";
    uint256 public constant decimals = 18;
    string public nizkpp;

    uint256 public constant INITIAL_SUPPLY = 10000;

    mapping(address => string) t_balances;
    address[] buyAddrs;                                         // 所有认购者地址
    mapping(address => mapping (address => string)) t_allowed;
    mapping(address => string) t_pubKey;                        // 地址和公钥对应结构

    LibTokenPailler.TokenPailler[] tokenPaillers;
    LibTokenRecord.TokenRecord[] tokenRecords;

    LibNizkParam.NizkParam internal param;

    event TransferPailler(address indexed from, address indexed to, string value);
    event ApprovalPailler(address indexed owner, address indexed spender, string value);
    event Notify(uint _errno, string _info);

    enum ErrorCode {
        NO_ERROR,
        BAD_PARAMETER,
        NO_PERMISSION,
        NIZK_ERROR,
        NO_BALANCE
    }

    function JuzixTokenManager() {
        register("TokenModuleManager","0.0.1.0","JuzixTokenManager", "0.0.1.0");
        //nizkpp = LibNIZK.nizk_setup();
        nizkpp = "yangzhou";
    }

    /// @dev 获取用户公钥
    /// @param _address 用户地址
    function getPubkey(address _address) constant public returns(string _pubKey){
        _pubKey = _pubKey.concat("{");
        _pubKey = _pubKey.concat( t_pubKey[_address].toKeyValue("pubKey"));
        _pubKey = _pubKey.concat("}");
        return _pubKey;
    }

    /// @dev 匹配当前用户公钥和地址
    /// @param _pubKey 用户公钥
    function setPubkey(string _pubKey) returns (uint){
        t_pubKey[tx.origin] = _pubKey;
        log("set pubKey success! msg sender:",tx.origin);
        errno= uint(ErrorCode.NO_ERROR);
        Notify(errno, "set pubKey success..");
        return errno;
    }

    /// @dev 设置流通股数
    /// @param _circulationShares 流通股数（密文）
    function setCirculationShares(string _circulationShares) returns (bool){
        if(tx.origin != owner){
            log("msg sender is not owner,no permission");
            errno= uint(ErrorCode.NO_PERMISSION);
            Notify(errno, "msg.sender is not owner,no permission..");
            return false;
        }

        for (uint i = 0; i < buyAddrs.length; ++i) {
            if( tx.origin == buyAddrs[i] ) {
                log("the admin has set the circulation shares yet !");
                errno= uint(ErrorCode.NO_PERMISSION);
                Notify(errno, "the admin has set the circulation shares yet..");
                return true;
            }
        }

        buyAddrs.push(tx.origin);
        t_balances[tx.origin] = _circulationShares;
        log("set circulation shares success!", "JuzixTokenManager");
        errno= uint(ErrorCode.NO_ERROR);
        Notify(errno, "set circulation shares success!");
        return true;
    }


    /// @dev 股权登记
    /// @param _param 零知识证明信息
    /// @param _to 股权登记地址
    function buyFrom(string _param,address _to) public returns (uint) {

        //判断是否是管理员
        if(tx.origin != owner){
            log("msg.sender is not admin,no permission", "JuzixTokenManager");
            errno= uint(ErrorCode.NO_PERMISSION);
            Notify(errno, "msg.sender is not admin,no permission..");
            return errno;
        }

        if (tx.origin == _to){
            log("tx.origin equals _to,could not transfer to oneself!", "JuzixTokenManager");
            errno= uint(ErrorCode.NO_PERMISSION);
            Notify(errno, "could not transfer to oneself!");
            return errno;
        }

        if (bytes(t_balances[tx.origin]).length == 0) {
            log("This account has no enough balance", "JuzixTokenManager");
            errno= uint(ErrorCode.NO_BALANCE);
            Notify(errno, "msg.sender is not admin,no permission..");
            return errno;
        }

        if (!param.jsonParse(_param)) {
            log("param json is invalid", "JuzixTokenManager");
            errno = uint(ErrorCode.BAD_PARAMETER);
            Notify(errno, "bad param json as LibNizkParam");
            return errno;
        }

        param.nizkpp = nizkpp;
        param.balapubcipher = t_balances[tx.origin];

        string memory t_result;
        if(bytes(t_balances[_to]).length == 0){
            t_balances[_to] = param.trabpubcipher;
            buyAddrs.push(_to);
            log("first time register stock....","JuzixTokenManager");
        } else {
            // 追加认购数量
            log("register stock again....","JuzixTokenManager");

            param.cipher1 = t_balances[_to];
            param.cipher2 = param.trabpubcipher;

            if(bytes(param.cipher1).length == 0){
                log("nizk param ,param cipher1:",param.cipher1);
            } if(bytes(param.cipher2).length == 0){
                log("nizk param ,param cipher2:",param.cipher2);
            } if(bytes(param.pais).length == 0){
                log("nizk param ,param pais:",param.pais);
            } if(bytes(param.balapubcipher).length == 0){
                log("nizk param ,param balapubcipher:",param.balapubcipher);
            } if(bytes(param.traapubcipher).length == 0){
                log("nizk param ,param traapubcipher:",param.traapubcipher);
            } if(bytes(param.trabpubcipher).length == 0){
                log("nizk param ,param trabpubcipher:",param.trabpubcipher);
            } if(bytes(param.apukkey).length == 0){
                log("nizk param ,param apukkey:",param.apukkey);
            } if(bytes(param.bpukkey).length == 0){
                log("nizk param ,param bpukkey:",param.bpukkey);
            }if(bytes(param.nizkpp).length == 0){
                log("nizk param ,param nizkpp:",param.nizkpp);
            }

            t_result = LibNIZK.nizk_apubcipheradd(param);
            log("nizk result,add t_result:",t_result);
            if(bytes(t_result).length == 0){
                throw;
            }
            t_balances[_to] = t_result;
        }

        //总数扣减
        param.cipher1 = t_balances[owner];
        param.cipher2 = param.traapubcipher;

        log("nizk param ,param cipher1:",param.cipher1);
        log("nizk param ,param cipher2:",param.cipher2);
        log("nizk param ,param pais:",param.pais);
        log("nizk param ,param balapubcipher:",param.balapubcipher);
        log("nizk param ,param traapubcipher:",param.traapubcipher);
        log("nizk param ,param trabpubcipher:",param.trabpubcipher);
        log("nizk param ,param apukkey:",param.apukkey);
        log("nizk param ,param bpukkey:",param.bpukkey);
        // log("nizk param ,param nizkpp:",param.nizkpp);

        t_result = LibNIZK.nizk_apubciphersub(param);
        log("nizk result,sub t_result:",t_result);
        if(bytes(t_result).length != 0){
            t_balances[owner] = t_result;
        }else {
            throw;
        }

        // 添加登记记录
        LibTokenRecord.TokenRecord memory tokenRecordTmp = LibTokenRecord.TokenRecord({
        buyAddr : _to,
        buyTime : now * 1000,
        tranferType : 1,
        name : name,
        symbol : symbol,
        amountIn : param.trabpubcipher,
        amountOut : param.traapubcipher,
        deleted : false
        });
        tokenRecords.push(tokenRecordTmp);
        delete param;
        log("register stock success");
        errno = uint(ErrorCode.NO_ERROR);
        Notify(errno, "register stock success..");
        return errno;
    }

    /// @dev 转账
    /// @param _param 零知识证明结构信息
    /// @param _to 接收者地址
    function transferPaillier(string _param,address _to) public returns (bool) {

        address _from = msg.sender;
        log("exec transferPaillier,msg.sender ->",msg.sender);
        log("exec transferPaillier,_to ->",_to);

        if (bytes(t_balances[tx.origin]).length == 0) {
            log("This account has no enough balance", "JuzixTokenManager");
            errno= uint(ErrorCode.NO_BALANCE);
            Notify(errno, "msg.sender is not admin,no permission..");
            return false;
        }

        if (tx.origin == _to){
            log("tx.origin equals _to,could not transfer to oneself!", "JuzixTokenManager");
            errno= uint(ErrorCode.NO_PERMISSION);
            Notify(errno, "could not transfer to oneself!");
            return false;
        }

        if (!param.jsonParse(_param)) {
            log("param json is invalid", "JuzixTokenManager");
            errno = uint(ErrorCode.BAD_PARAMETER);
            Notify(errno, "bad param json as LibNizkParam");
            return false;
        }

        param.nizkpp = nizkpp;
        param.balapubcipher = t_balances[tx.origin];

        // 接收金额
        string memory t_result;
        if(bytes(t_balances[_to]).length == 0){

            bool flag = true;
            for (uint i = 0 ; i < buyAddrs.length ; ++i) {
                if( _to == buyAddrs[i] ) {
                    flag = false;
                }
            }
            if(flag){
                buyAddrs.push(_to);
                t_balances[_to] = param.trabpubcipher;
            }
            log("this user has not record of registered stock!","JuzixTokenManager");

        }else{

            param.cipher1 = t_balances[_to];
            param.cipher2 = param.trabpubcipher;

            if(bytes(param.cipher1).length == 0){
                log("nizk param ,param cipher1:",param.cipher1);
            } if(bytes(param.cipher2).length == 0){
                 log("nizk param ,param cipher2:",param.cipher2);
            } if(bytes(param.pais).length == 0){
                log("nizk param ,param pais:",param.pais);
            } if(bytes(param.traapubcipher).length == 0){
                log("nizk param ,param traapubcipher:",param.traapubcipher);
            } if(bytes(param.trabpubcipher).length == 0){
                log("nizk param ,param trabpubcipher:",param.trabpubcipher);
            } if(bytes(param.apukkey).length == 0){
                log("nizk param ,param apukkey:",param.apukkey);
            } if(bytes(param.bpukkey).length == 0){
                log("nizk param ,param bpukkey:",param.bpukkey);
            }if(bytes(param.nizkpp).length == 0){
                log("nizk param ,param nizkpp:",param.nizkpp);
            }

            t_result = LibNIZK.nizk_apubcipheradd(param);
            log("nizk result,t_result:",t_result);
            if(bytes(t_result).length != 0){
                t_balances[_to] = t_result;
                log("add success..",_to);
            }else{
                log("transfer fail,add fail..",t_result);
                throw;
            }
        }

        // 扣减
        param.cipher1 = t_balances[tx.origin];
        param.cipher2 = param.traapubcipher;

        log("nizk param ,param cipher1:",param.cipher1);
        log("nizk param ,param cipher2:",param.cipher2);
        log("nizk param ,param pais:",param.pais);
        log("nizk param ,param balapubcipher:",param.balapubcipher);
        log("nizk param ,param traapubcipher:",param.traapubcipher);
        log("nizk param ,param trabpubcipher:",param.trabpubcipher);
        log("nizk param ,param apukkey:",param.apukkey);
        log("nizk param ,param bpukkey:",param.bpukkey);
        //log("nizk param ,param nizkpp:",param.nizkpp);

        t_result = LibNIZK.nizk_apubciphersub(param);
        log("nizk result,t_result:",t_result);
        if(bytes(t_result).length != 0){
            t_balances[tx.origin] = t_result;
            log("deduction success..",tx.origin);
        }else{
            log("transfer fail,deduction fail...",t_result);
            throw;
        }

        //写入转账记录
        LibTokenPailler.TokenPailler memory tokenPaillerTmp = LibTokenPailler.TokenPailler({
            fromAddr : tx.origin,
            toAddr : _to,
            tranferTime : now * 1000,
            tranferType : 1,
            amountIn : param.trabpubcipher,
            amountOut : param.traapubcipher,
            deleted : false
        }); 
        tokenPaillers.push(tokenPaillerTmp);
        delete param;
        log("transferPaillier build LibTokenPailler.TokenPailler success..","JuzixTokenManager");
        errno = uint(ErrorCode.NO_ERROR);
        Notify(errno, "transfer success..");
        return true;
    }

    /// @dev 账户余额查询
    /// @param _owner 待查询账户地址
    /// @return _balance 当前账户的余额（加密数据）
    function balanceOfPaillier(address _owner) constant returns (string _balance) {
        _balance = _balance.concat("{");
        _balance = _balance.concat( t_balances[_owner].toKeyValue("balance"),",");
        _balance = _balance.concat( t_pubKey[_owner].toKeyValue("pubKey"));
        _balance = _balance.concat("}");
        return _balance;
    }

    /// @dev 返回发行总量
    /// @return 总发行量
    function totalSupplyPaillier() constant returns (string _supply) {
    } 

    /// @dev 授权指定用户代付金额
    function approvePaillier(address _spender, string _value) returns (bool) {
        t_allowed[msg.sender][_spender] = _value;
        ApprovalPailler(msg.sender, _spender, _value);
        return true;
    }

    /// @dev 授权代付额度查询
    function allowancePaillier(address _owner, address _spender) constant returns (string remaining) {
        return t_allowed[_owner][_spender];
    }

    /// @dev 查询所有账户余额
    /// @param _buyAddr       查询账户,为""查询所有
    /// @param _pageNum       页码
    /// @param _pageSize      页面大小
    function listAllBuyBalance(address _buyAddr, uint _pageNum, uint _pageSize) constant public returns(string _json){
        _json = _json.concat("{");
        _json = _json.concat(uint(0).toKeyValue("ret"), ",");
        _json = _json.concat("\"data\":{");
        _json = _json.concat(uint(buyAddrs.length).toKeyValue("total"), ",");
        _json = _json.concat("\"items\":[");

        uint n = 0;
        uint m = 0;
        for (uint i = 0 ; i < buyAddrs.length ; ++i) {
            if(_buyAddr != address(0) && buyAddrs[i] != _buyAddr) {
                continue;
            }
            if (n >= _pageNum * _pageSize && n < (_pageNum + 1) * _pageSize) {
                if (m > 0) {
                    _json = _json.concat(",");
                }
                _json = _json.concat("{");
                _json = _json.concat( uint(buyAddrs[i]).toAddrString().toKeyValue("buyAddr"),",");
                _json = _json.concat( t_balances[buyAddrs[i]].toKeyValue("amount"));
                _json = _json.concat("}");
                m++;
            }
            if (n >= (_pageNum + 1) * _pageSize) {
                break;
            }
            n++;
        }
        _json = _json.concat("]}}");
    }

    /// @dev 获取转账记录
    /// @param _account       查询账户,为""查询所有
    /// @param _tranferType   1 转出 2 转入
    /// @param _pageNum       页码
    /// @param _pageSize      页面大小
    function pageByAccount(address _account, uint _tranferType,uint _pageNum, uint _pageSize) constant public returns(string _json) {
        _json = _json.concat("{");
        _json = _json.concat(uint(0).toKeyValue("ret"), ",");
        _json = _json.concat("\"data\":{");
        _json = _json.concat(uint(tokenPaillers.length).toKeyValue("total"), ",");
        _json = _json.concat("\"items\":[");

        uint n = 0;
        uint m = 0;
        if(tx.origin == owner){
            for (uint i = 0 ; i < tokenPaillers.length ; ++i) {
                if ( !tokenPaillers[i].deleted ) {
                    if (n >= _pageNum * _pageSize && n < (_pageNum + 1) * _pageSize) {
                        if (m > 0) {
                            _json = _json.concat(",");
                        }
                        _json = _json.concat(tokenPaillers[i].toJson());
                        m++;
                    }
                    if (n >= (_pageNum + 1) * _pageSize) {
                        break;
                    }
                    n++;
                }
            }
        }else{
            for (uint j = 0 ; j < tokenPaillers.length ; ++j) {
                if ( ((_tranferType == 1 && tokenPaillers[j].fromAddr == _account)
                || (_tranferType == 2 && tokenPaillers[j].toAddr == _account))
                && !tokenPaillers[j].deleted) {
                    if (n >= _pageNum * _pageSize && n < (_pageNum + 1) * _pageSize) {
                        if (m > 0) {
                            _json = _json.concat(",");
                        }
                        _json = _json.concat(tokenPaillers[j].toJson());
                        m++;
                    }
                    if (n >= (_pageNum + 1) * _pageSize) {
                        break;
                    }
                    n++;
                }
            }
        }

        _json = _json.concat("]}}");
    }

    /// @dev 获取认筹记录
    /// @param _account       查询账户,为""查询所有
    /// @param _pageNum       页码
    /// @param _pageSize      页面大小
    function pageBuyRecordByAccount(address _account,uint _pageNum, uint _pageSize) constant public returns(string _json) {
        _json = _json.concat("{");
        _json = _json.concat(uint(0).toKeyValue("ret"), ",");
        _json = _json.concat("\"data\":{");
        _json = _json.concat(uint(tokenRecords.length).toKeyValue("total"), ",");
        _json = _json.concat("\"items\":[");

        uint n = 0;
        uint m = 0;
        if(tx.origin == owner){
            //管理员返回所有
            for (uint i = 0 ; i < tokenRecords.length ; ++i) {
                if ( !tokenRecords[i].deleted) {
                    if (n >= _pageNum * _pageSize && n < (_pageNum + 1) * _pageSize) {
                        if (m > 0) {
                            _json = _json.concat(",");
                        }
                        _json = _json.concat(tokenRecords[i].toJson());
                        m++;
                    }
                    if (n >= (_pageNum + 1) * _pageSize) {
                        break;
                    }
                    n++;
                }
            }
        }else {
            for (uint j = 0 ; j < tokenRecords.length ; ++j) {
                if ( tokenRecords[j].buyAddr == _account && !tokenRecords[j].deleted) {
                    if (n >= _pageNum * _pageSize && n < (_pageNum + 1) * _pageSize) {
                        if (m > 0) {
                            _json = _json.concat(",");
                        }
                        _json = _json.concat(tokenRecords[j].toJson());
                        m++;
                    }
                    if (n >= (_pageNum + 1) * _pageSize) {
                        break;
                    }
                    n++;
                }
            }
        }

        _json = _json.concat("]}}");
    }

    /// @dev 判断是否是管理员
    function isAdmin() constant public returns(string _json){
        _json = _json.concat("{");
        if(msg.sender == owner){
            _json = _json.concat(t_balances[msg.sender].toKeyValue("circulationShares"),",");
            _json = _json.concat(uint(1).toKeyValue("isAdmin"));
        }else{
            _json = _json.concat(uint(0).toKeyValue("circulationShares"),",");
            _json = _json.concat(uint(2).toKeyValue("isAdmin"));
        }
        _json = _json.concat("}");
    }

    /// @dev 修改合约管理员
    function setOwner (address _address) public returns(bool){
        if(tx.origin != owner){
            log("msg sender is not owner,no permission","JuzixTokenManager");
            errno = uint(ErrorCode.NO_PERMISSION);
            Notify(errno, "only admin can update owner");
            return false;
        }
        owner = _address;
        log("update owner success, owner:",_address);
        errno = uint(ErrorCode.NO_ERROR);
        Notify(errno, "update owner success");
        return true;

    }

    /// @dev 获取零知识证明结构
    function getNizkStruct() constant public returns (string _ret){
        return nizkpp;
    }

}
