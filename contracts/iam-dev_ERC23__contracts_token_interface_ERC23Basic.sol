pragma solidity ^0.4.18;

import '../../../installed_contracts/zeppelin-solidity/contracts/token/ERC20Basic.sol';

/**
 *
 * @title ERC23Basic additions to ERC20Basic
 *        derived from OpenZeppelin solidity library
 * @dev Simpler version of ERC23 interfaceERC23 additions to ERC20Basic
 * @dev see also: https://github.com/Dexaran/ERC23-tokens
 *                https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * Created by IaM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: ERC23Basic.sol
 * location: ERC23/contracts/token/interface/
 *
*/
contract ERC23Basic is ERC20Basic {
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);
    function contractFallback(address _origin, address _to, uint _value, bytes _data) internal returns (bool success);
    function isContract(address _addr) internal returns (bool is_contract);
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes indexed _data);
}
