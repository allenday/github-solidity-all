pragma solidity ^0.4.2;

import "../utillib/LibInt.sol";
import "../utillib/LibString.sol";

library LibTokenPailler{

	using LibInt for *;
	using LibString for *;
	using LibTokenPailler for *;

	struct TokenPailler {
		address 				fromAddr;
		address 				toAddr;
		uint 					tranferTime;
		uint 					tranferType; 		// 1 转入, 2 转出
	    string 					amountIn;			// 转入代币数量
	    string 					amountOut;			// 转出代币数量
		bool 					deleted;
	}

	function toJson(TokenPailler storage _self) constant internal returns(string _json){
		_json = _json.concat("{");
		_json = _json.concat( uint(_self.fromAddr).toAddrString().toKeyValue("fromAddr"),",");
		_json = _json.concat( uint(_self.toAddr).toAddrString().toKeyValue("toAddr"),",");
		_json = _json.concat( uint(_self.tranferTime).toKeyValue("tranferTime"),",");
		//_json = _json.concat( uint(_self.tranferType).toKeyValue("tranferType"),",");
		_json = _json.concat( _self.amountIn.toKeyValue("amountIn"),",");
		_json = _json.concat( _self.amountOut.toKeyValue("amountOut"));
		_json = _json.concat("}");
	}

	function clear(TokenPailler storage _self) internal{
		_self.fromAddr = 0;
		_self.toAddr = 0;
		_self.tranferType = 1;
		_self.amountIn = "";
		_self.amountOut = "";
		_self.tranferTime = 0;
		_self.deleted = false;
	}
}
