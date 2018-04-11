pragma solidity ^0.4.18;


/**
 * @title Upgradeable ERC23 Token 
 * @dev Interface for Upgradeable Token
 *
 * Created by IaM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: Upgradeable23Token.sol
 * location: ERC23/contracts/token/interface/
 *
*/
contract Upgradeable23Token {
	bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    
    function setName(bytes32 _name) public returns (bool success);
    function setSymbol(bytes32 _symbol) public returns (bool success);
    function setDecimals(uint256 _decimals) public returns (bool success);
    function addSupply(uint256 _amount) public returns (bool success);
    function subSupply(uint256 _amount) public returns (bool success);
}
