pragma solidity ^0.4.15;


contract MigrationAgent {
  /*
    MigrationAgent contracts need to have this exact constant!
    it is intended to be identify the contract, since there is no way to tell
    if a contract is indeed an instance of the right type of contract otherwise
  */
  uint256 public constant MIGRATE_MAGIC_ID = 0x6e538c0d750418aae4131a91e5a20363;

  /*
    A contract implementing this interface is assumed to implement the neccessary
    access controls. E.g;
    * token being migrated FROM is the only one allowed to call migrateTo
    * token being migrated TO has a minting function that can only be called by
      the migration agent
  */
  function migrateTo(address beneficiary, uint256 amount) external;
}
