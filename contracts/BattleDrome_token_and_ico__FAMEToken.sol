pragma solidity ^0.4.11;

import "ERC20Standard.sol";

//------------------------------------------------------------------------------------------------
// FAME ERC20 Token, based on ERC20Standard interface
// Copyright 2017 BattleDrome
//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------
// LICENSE
//
// This file is part of BattleDrome.
// 
// BattleDrome is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// BattleDrome is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with BattleDrome.  If not, see <http://www.gnu.org/licenses/>.
//------------------------------------------------------------------------------------------------

contract FAMEToken is ERC20Standard {

	function FAMEToken() {
		totalSupply = 2100000 szabo;			//Total Supply (including all decimal places!)
		name = "Fame";							//Pretty Name
		decimals = 12;							//Decimal places (with 12 decimal places 1 szabo = 1 token in uint256)
		symbol = "FAM";							//Ticker Symbol (3 characters, upper case)
		version = "FAME1.0";					//Version Code
		balances[msg.sender] = totalSupply;		//Assign all balance to creator initially for distribution from there.
	}

	//Burn _value of tokens from your balance.
	//Will destroy the tokens, removing them from your balance, and reduce totalSupply accordingly.
	function burn(uint _value) {
		require(balances[msg.sender] >= _value && _value > 0);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
	}

	//Event to log any time someone burns tokens to the contract's event log:
	event Burn(
		address indexed _owner,
		uint _value
		);

}