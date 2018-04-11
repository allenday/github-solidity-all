pragma solidity ^0.4.11;

import "./HasNoElement.sol";
import "./HasNoTokens.sol";
import "./HasNoContracts.sol";

/** 
 * @title Base contract for contracts that should not own things.
 * @author Remco Bloemen <remco@2π.com>
 * @dev Solves a class of errors where a contract accidentally becomes owner of Element, Tokens or 
 * Owned contracts. See respective base contracts for details.
 */
contract NoOwner is HasNoElement, HasNoTokens, HasNoContracts {
}
