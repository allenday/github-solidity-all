pragma solidity ^0.4.18;

import "../registry/SSPRegistry.sol";
import "../registry/DSPRegistry.sol";
import "../registry/PublisherRegistry.sol";
import "../registry/AuditorRegistry.sol";
import "../registry/DepositRegistry.sol";


contract RegistryProvider {
  function replaceSSPRegistry(SSPRegistry newRegistry) public;
  function replaceDSPRegistry(DSPRegistry newRegistry) public;
  function replacePublisherRegistry(PublisherRegistry newRegistry) public;
  function replaceAuditorRegistry(AuditorRegistry newRegistry) public;
  function replaceSecurityDepositRegistry(DepositRegistry newRegistry) public;
  function getSSPRegistry() internal view returns (SSPRegistry);
  function getDSPRegistry() internal view returns (DSPRegistry);
  function getPublisherRegistry() internal view returns (PublisherRegistry);
  function getAuditorRegistry() internal view returns (AuditorRegistry);
  function getSecurityDepositRegistry() internal view returns (DepositRegistry);
}
