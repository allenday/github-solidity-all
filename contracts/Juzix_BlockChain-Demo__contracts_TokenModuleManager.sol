pragma solidity ^0.4.2;

import "./sysbase/OwnerNamed.sol";
import "./sysbase/BaseModule.sol";

contract TokenModuleManager is BaseModule {

    using LibString for *;
    using LibInt for *;

    string moduleName;
    string moduleText;
    string moduleVersion;
    string contractName;
    string contractVersion;
    string sysModuleId;     
    
    uint reversion;                

    // contractName => contractId ,eg : UserMananger => contract001
    mapping(string => string) innerContractMapping;

    enum MODULE_ERROR {
        NO_ERROR
    }

    enum ROLE_DEFINE {
        ROLE_SUPER,
        ROLE_ADMIN,
        ROLE_PLAIN
    }

    event Notify(uint _error, string _info);

    function TokenModuleManager(){
        reversion = 0;
        register("TokenModuleManager","0.0.1.0");

        moduleName = "TokenModuleManager";      //设置模块名称【根据实际修改】
        moduleVersion = "0.0.1.0";              //设置模块版本号
        sysModuleId = "tokenModuleId001";       //显示指定模块ID
        moduleText = "股权交易";                  //显示模块名称

        string memory _json = "{";
        _json = _json.concat("\"moduleId\":\"", sysModuleId, "\",");
        _json = _json.concat("\"moduleName\":\"", moduleName, "\",");
        _json = _json.concat("\"moduleText\":\"", moduleText, "\",");
        _json = _json.concat("\"moduleVersion\":\"", moduleVersion, "\",");
        _json = _json.concat("\"icon\":\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA4ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMDY3IDc5LjE1Nzc0NywgMjAxNS8wMy8zMC0yMzo0MDo0MiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDoyNTBjNTFiOS1jMDc2LWM4NGEtOWEyOS1mMTNjMGY3NGExNjIiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NDg5QkFEN0E3QTk0MTFFNzlBRjVBNzc2RDE2RThBQUQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NDg5QkFENzk3QTk0MTFFNzlBRjVBNzc2RDE2RThBQUQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTUgKE1hY2ludG9zaCkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDoyYWQ1MGExYy1lY2Y4LTRiYTYtYmZjNy02Y2VlMmVhMDQ2YWIiIHN0UmVmOmRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDowZWU4MWJlYS1iZTI2LTExN2EtYmY4YS05ZWFhNmVmNDVmM2QiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7MPbc/AAAEF0lEQVR42sSZWUhVURSGz71p5FhmFlYmRTlkUtANw7c0IvIhJMiiwayHspF8DDLKnoIeRH2IsjkbycKKoMHHMk0qG9SHCLWssMk0QUv7F/wnDod7z3TvsQUf595z9t3r9+y911576WloaFAcmBcsAkuAD6SAaSCKz/vBe9AOmkA9aATDdh2F2Ww/HewA68AP8ABcBa2gE/SxXTRIAqkgG5wA48EFUAW6Qi0wHhwCa8FpkAdaDNp/Jc/BFd7LBEXgBbgISsEXK0NlZqvBK/CHQ1liIi6QtfC3c9iX9Flg9iOPwRyUt1sBcjmkjUpoTeZuDafJLvDbzhuMBLUgmR2FWpzCxeOjj1r6tCQwjHNEVuJK0Ku4Z7300U+fYVYEVsrQg41gSHHfhujLQ9+GAgs459aDQWX0bJA+cxkp/AqUUFIO1rg8rEbDvYYaEvwJPMyg+9Sph4iIiMngLhgGH8EGm12I70ugTB9mZoBnjHM9QQi8hssqzS3Z2jIGBgZabXQziVvkAtChvsFicCYYcZrYpp9CPpt99HC3KlY78HKCVocotim6N9jkoJ9qavKqWYls/C9DIHA7uAdGwCfZe20Or2qyDX4XbRIYc9ipkzk3WzIWiLgt33H9jMsy3Pfi83CQf+x9SefkDS4Ejx2Kk+G7hc/7tM9CIE6hJp+XOdsbm+Ik37vBHE+sDPeWB2ibCZpAsU2BoilVBCaCDzbEeTiJM3SrtQbPZunaTsSljqNUge9ZNgRKRp4oHceAnzZ+WMIcUW9x4DpERFLcGCYAyXwu38/hfpRFP6IpRo2DIxbfnpxBjhg0mQ+O8fNBWTC655KsHrUzzrKTSGBMMwvSECdnjGZGejO7bJIt52Eh3bFwzGiTN9gNppqIGyfDZ1GcYiGVP4k+E0zayCmxWwS2gXSTxlUOtiwjm6KZCoEsTX2DkkEsNnh7W3HZ7EJ6lY++iwyei6YmLw/VSwOIy+LByS0rh4+ZAZ6JpnoR+ARM0MU11U6BcBcFSog77ud+BsNWo5cZx3mwxU/DdMV9y/Fzbws1DXs1i6DQzyptHgWB7/wkrIXU9C/l72KqXaprvMlhFcGqvWU5RGv7WS7p0lcWJDC+BiuCOZcEabJnSwCfq9ZttIcmubGH+2fsfxAXS997tUUl/blYhvmhbOour169hdNnPes1hpWF3byeHSWRqjiFRSTT0scgT/eSjN50ebhj6SOaPgetVrd+sajToalChdp87Ft85NOn5fKbWtTZxtBTx5JEfAiEqSUW6fMAfQQsUlmpsMrCkfLtWJ74JeGc50BYBn/bzr4yuWpNE1Y7TqSIvpOH6m88Gj5iytapOTrIHpvEUko2N/44bl+Vio0iuifIf0PkMLimUHw0n/dRRDuDvoQuR/+G+CvAAGjg+nJ1aHTpAAAAAElFTkSuQmCC\"", ",");
        _json = _json.concat("\"moduleEnable\":", "0", ",");    //模块开关：0-放权；1-控权【需要修改】
        _json = _json.concat("\"moduleType\":", "1", ",");      // 模块类型 1 系统模块
        _json = _json.concat("\"moduleUrl\":\"http://192.168.9.18/dapp-token/#\"", ",");
        _json = _json.concat("\"moduleDescription\":\"", moduleName.concat(moduleVersion, "-Token代币模块"), "\"");
        _json = _json.concat("}");
        
        uint ret = addModule(_json); 
        sysModuleId = ret.recoveryToString();
        log("construct sysModuleId:",sysModuleId);
       
    }

}
