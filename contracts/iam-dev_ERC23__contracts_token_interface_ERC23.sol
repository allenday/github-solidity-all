pragma solidity ^0.4.18;

import '../../../installed_contracts/zeppelin-solidity/contracts/token/ERC20.sol';

/**
 *
 * @title ERC23 additions to ERC20
 *        derived from OpenZeppelin solidity library
 * @dev Simpler version of ERC23 interfaceERC23 additions to ERC20
 * @dev see also: https://github.com/Dexaran/ERC23-tokens
 *                https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * Created by IaM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: ERC23.sol
 * location: ERC23/contracts/token/interface/
 *
 */
contract ERC23 is ERC20{
    function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool success);
}
