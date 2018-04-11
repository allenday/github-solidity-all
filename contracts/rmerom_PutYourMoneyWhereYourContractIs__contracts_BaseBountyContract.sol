pragma solidity ^0.4.4;

import "./EnvironmentContractInterface.sol";

/**
 * Base contract for managing a specific bounty. Inherit from this contract
 * to create your own bounty.
 */
contract BaseBountyContract {
  address bountyManagerAddress;
  address activeTargetContract;

  modifier onlyFromBountyManager { 
    if (msg.sender != bountyManagerAddress) throw; 
    _;
  }
  
  function BaseBountyContract(address _bountyManagerAddress) { 
    bountyManagerAddress = _bountyManagerAddress;
  }
  
  /**
   * Creates a contract for the bug bounty challenger to try and break.
   * @return targetContract to challenge, environment that targetContract uses.
   */
  function challengeContract(address ownerToSet) onlyFromBountyManager returns (address, EnvironmentContractInterface) {
      EnvironmentContractInterface env = createTestingEnvironment();
      activeTargetContract = createTargetContract(env, ownerToSet);
      return (activeTargetContract, env);
  }
  
  /**
   * Override this method to create and return the address of the new target contract.
   * 
   * @param env the environment to dependency-inject to the new targetContract.
   * @param ownerToSet you may, at your own discretion, allow setting the owner of the targetContract
   *        to this address, if you'd like to make assertions about what owner can or cannot do.
   *        If you're not planning to have such assertions, ignore this parameter.
   */
  function createTargetContract(EnvironmentContractInterface env, address ownerToSet) internal returns (address);
  

  /**
   * Override this method to create and return the address an environment contract
   * (e.g. EnvironmentTestContract).
   */
  function createTestingEnvironment() internal returns (EnvironmentContractInterface);

  
  /**
   * Override this method and returns true if the activeTargetContract, which 
   * must have been deployed by challengeContract(), is in an invalid state. 
   */
  function assertInvalidState() onlyFromBountyManager returns (bool);
}

