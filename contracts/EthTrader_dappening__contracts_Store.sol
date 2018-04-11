pragma solidity ^0.4.17;

import "./Controlled.sol";

contract Store is Controlled {

    mapping(bytes20 => uint)    public values;

    event Set(bytes20 key, uint val);
    event Removed(bytes20 key);

    function Store(bool _isDev, uint _decimals) {
      set("PROP_STAKE", 1000*10**_decimals);
      set("SIG_VOTE", 500*10**_decimals);
      if(_isDev) {
          set("SIG_VOTE_DELAY", 0);
          set("PROP_DURATION", 2);
      } else {
          set("SIG_VOTE_DELAY", 43);
          set("PROP_DURATION", 12343);//43200);
      }
      set("TOKEN_AGE_DAY_CAP", 200*10**_decimals);
    }

    function set(bytes20 _key, uint _val) public onlyController {
        values[_key] = _val;
        Set(_key, _val);
    }

    function remove(bytes20 _key) public onlyController {
        delete values[_key];
        Removed(_key);
    }

}
