pragma solidity ^0.4.18;

import "../common/SafeOwnable.sol";
import "../common/ERC20.sol";
import "../common/WithToken.sol";
import "../registry/SSPRegistry.sol";
import "../registrar/SSPRegistrar.sol";
import "../registry/DSPRegistry.sol";
import "../registrar/DSPRegistrar.sol";
import "../registry/PublisherRegistry.sol";
import "../registrar/PublisherRegistrar.sol";
import "../registry/AuditorRegistry.sol";
import "../registrar/AuditorRegistrar.sol";
import "../registry/DepositRegistry.sol";
import "../channel/StateChannelListener.sol";


contract PapyrusDAO is
  WithToken,
  RegistryProvider,
  StateChannelListener,
  SSPRegistrar,
  DSPRegistrar,
  PublisherRegistrar,
  AuditorRegistrar,
  SafeOwnable
{

  // EVENTS

  event DepositsTransferred(address newDao, uint256 sum);
  event SSPRegistryReplaced(address from, address to);
  event DSPRegistryReplaced(address from, address to);
  event PublisherRegistryReplaced(address from, address to);
  event AuditorRegistryReplaced(address from, address to);
  event SecurityDepositRegistryReplaced(address from, address to);

  // PUBLIC FUNCTIONS

  function PapyrusDAO(
    ERC20 _token,
    SSPRegistry _sspRegistry,
    DSPRegistry _dspRegistry,
    PublisherRegistry _publisherRegistry,
    AuditorRegistry _auditorRegistry,
    DepositRegistry _securityDepositRegistry
  )
    public
  {
    token = _token;
    sspRegistry = _sspRegistry;
    dspRegistry = _dspRegistry;
    publisherRegistry = _publisherRegistry;
    auditorRegistry = _auditorRegistry;
    securityDepositRegistry = _securityDepositRegistry;
  }

  function replaceSSPRegistry(SSPRegistry _sspRegistry) public onlyOwner {
    address old = sspRegistry;
    sspRegistry = _sspRegistry;
    SSPRegistryReplaced(old, sspRegistry);
  }

  function replaceDSPRegistry(DSPRegistry _dspRegistry) public onlyOwner {
    address old = dspRegistry;
    dspRegistry = _dspRegistry;
    DSPRegistryReplaced(old, dspRegistry);
  }

  function replacePublisherRegistry(PublisherRegistry _publisherRegistry) public onlyOwner {
    address old = publisherRegistry;
    publisherRegistry = _publisherRegistry;
    PublisherRegistryReplaced(old, publisherRegistry);
  }

  function replaceAuditorRegistry(AuditorRegistry _auditorRegistry) public onlyOwner {
    address old = auditorRegistry;
    auditorRegistry = _auditorRegistry;
    AuditorRegistryReplaced(old, auditorRegistry);
  }

  function replaceSecurityDepositRegistry(DepositRegistry _securityDepositRegistry) public onlyOwner {
    address old = securityDepositRegistry;
    securityDepositRegistry = _securityDepositRegistry;
    SecurityDepositRegistryReplaced(old, securityDepositRegistry);
  }

  function replaceChannelContractAddress(address newChannelContract) public onlyOwner {
    require(newChannelContract != address(0));
    ChannelContractAddressChanged(channelContractAddress, newChannelContract);
    channelContractAddress = newChannelContract;
  }

  function transferDepositsToNewDao(address newDao) public onlyOwner {
    uint256 depositSum = token.balanceOf(this);
    token.transfer(newDao, depositSum);
    // TODO: What if transfer is failed?
    DepositsTransferred(newDao, depositSum);
  }

  function kill() public onlyOwner {
    selfdestruct(owner);
  }

  // INTERNAL FUNCTIONS

  function getSSPRegistry() internal view returns (SSPRegistry) {
    return sspRegistry;
  }

  function getDSPRegistry() internal view returns (DSPRegistry) {
    return dspRegistry;
  }

  function getPublisherRegistry() internal view returns (PublisherRegistry) {
    return publisherRegistry;
  }

  function getAuditorRegistry() internal view returns (AuditorRegistry) {
    return auditorRegistry;
  }

  function getSecurityDepositRegistry() internal view returns (DepositRegistry) {
    return securityDepositRegistry;
  }
}
