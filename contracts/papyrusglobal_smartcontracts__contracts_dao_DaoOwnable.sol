pragma solidity ^0.4.18;

import "../common/SafeOwnable.sol";


contract DaoOwnable is SafeOwnable {

  // EVENTS

  event DaoOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  // PUBLIC FUNCTIONS

  /// @dev Allows the current owner to transfer control of the contract to a newDao.
  /// @param newDao The address to transfer ownership to.
  function transferDao(address newDao) public onlyOwner {
    require(newDao != address(0));
    dao = newDao;
    DaoOwnershipTransferred(owner, newDao);
  }

  // MODIFIERS

  /// @dev Throws if called by any account other than the DAO.
  modifier onlyDao() {
    require(msg.sender == dao);
    _;
  }

  modifier onlyDaoOrOwner() {
    require(msg.sender == dao || msg.sender == owner);
    _;
  }

  // FIELDS

  address public dao = address(0);
}
