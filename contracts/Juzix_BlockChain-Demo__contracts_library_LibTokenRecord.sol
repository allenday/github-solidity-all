pragma solidity ^0.4.2;

import "../utillib/LibInt.sol";
import "../utillib/LibString.sol";

library LibTokenRecord {

	using LibInt for *;
	using LibString for *;
	using LibTokenRecord for *;

	struct TokenRecord {
		address 				buyAddr;
		uint 					buyTime;
		uint 					tranferType; 		// 认筹类型 1(默认)
		string 					name;				// 代币名称
		string 					symbol;				// 代币简称
		string 					amountIn;			// 转入代币数量
		string 					amountOut;			// 转出代币数量
		bool 					deleted;
	}

	function toJson(TokenRecord storage _self) constant internal returns(string _json){
		_json = _json.concat("{");
		_json = _json.concat( uint(_self.buyAddr).toAddrString().toKeyValue("buyAddr"),",");
		_json = _json.concat( uint(_self.buyTime).toKeyValue("buyTime"),",");
		_json = _json.concat( uint(_self.tranferType).toKeyValue("tranferType"),",");
		_json = _json.concat( _self.amountIn.toKeyValue("amountIn"),",");
		_json = _json.concat( _self.amountOut.toKeyValue("amountOut"),",");
		_json = _json.concat( _self.symbol.toKeyValue("symbol"),",");
		_json = _json.concat( _self.name.toKeyValue("name"),"");
		_json = _json.concat("}");
	}

	function clear(TokenRecord storage _self) internal{
		_self.buyAddr = 0;
		_self.buyTime = 0;
		_self.tranferType = 1;
		_self.name = "";
		_self.symbol = "";
		_self.amountIn = "";
		_self.amountOut = "";
		_self.deleted = false;
	}
}
