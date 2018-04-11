pragma solidity ^0.4.18;

import '../Utils.sol';
import './interface/Upgradeable23Token.sol';
import './Standard23Token.sol';
import '../../installed_contracts/zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../../installed_contracts/zeppelin-solidity/contracts/math/SafeMath.sol';

 /**
  * @title UpgradeableStandard23Token
  *
  * Created by IaM <DEV> (Elky Bachtiar) 
  * https://www.iamdeveloper.io
  *
  *
  * file: Upgradeable23Token.sol
  * location: ERC23/contracts/token/interface/
  *
 */

contract UpgradeableStandard23Token is Utils, Ownable, Upgradeable23Token, Standard23Token {
    using SafeMath for uint256;

    /**
     * @dev Change the token name
     * 
     * @param _name address The new name of the Token
     * @return bool successful or not
    */
    function setName(bytes32 _name) public onlyOwner returns (bool success) {
        require(_name != name);
        name = _name;
        return true;
    }

    /**
     * @dev Change the token symbol
     * 
     * @param _symbol address The new symbol of the Token
     * @return bool successful or not
    */
    function setSymbol(bytes32 _symbol) public onlyOwner returns (bool success)
    {
        require(_symbol != symbol);
        symbol = _symbol;
        return true;
    }

    function setDecimals(uint256 _decimals) 
      public 
      onlyOwner
      greaterOrEqualThanZero(_decimals)
      returns (bool success) {
        require(_decimals != decimals);
        decimals = _decimals;
        return true;
    }

    function addSupply(uint256 _amount) 
      public
      onlyOwner
      greaterThanZero(_amount)  
      returns (bool success)
    {
        require(balances[msg.sender].add(_amount) > balances[msg.sender]); // Detect balance overflow
        require(totalSupply.add(_amount) > totalSupply);                    // Detect balance overflow
        balances[msg.sender] = balances[msg.sender].add(_amount);
        totalSupply = totalSupply.add(_amount);
        return true;
    }

    function subSupply(uint256 _amount) 
      public
      onlyOwner
      greaterThanZero(_amount)  
      returns (bool success)
    {
        require(balances[msg.sender].sub(_amount) < balances[msg.sender]); // Detect balance underflow
        require(totalSupply.sub(_amount) < totalSupply);                   // Detect balance underflow
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        return true;
    }
}
