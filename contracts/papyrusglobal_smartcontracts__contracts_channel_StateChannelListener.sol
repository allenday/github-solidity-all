pragma solidity ^0.4.18;

import "../common/Ownable.sol";
import "../dao/RegistryProvider.sol";
import "./ChannelApi.sol";


contract StateChannelListener is RegistryProvider, ChannelApi {

  // EVENTS

  event ChannelContractAddressChanged(address previousAddress, address newAddress);

  // PUBLIC FUNCTIONS

  function applyRuntimeUpdate(
    address from,
    address to,
    uint64 totalImpressions,
    uint64 fraudImpressions
  )
    public
    onlyChannelContract
  {
    uint256[2] memory karmaDiff = [totalImpressions, uint256(0)];
    if (getDSPRegistry().isRegistered(from)) {
      getDSPRegistry().applyKarmaDiff(from, karmaDiff);
    } else if (getSSPRegistry().isRegistered(from)) {
      getSSPRegistry().applyKarmaDiff(from, karmaDiff);
    }

    karmaDiff[1] = fraudImpressions;
    if (getSSPRegistry().isRegistered(to)) {
      karmaDiff[0] = 0;
      getSSPRegistry().applyKarmaDiff(to, karmaDiff);
    } else if (getPublisherRegistry().isRegistered(to)) {
      karmaDiff[0] = totalImpressions;
      getPublisherRegistry().applyKarmaDiff(to, karmaDiff);
    }
  }

  function applyAuditorsCheckUpdate(address /*from*/, address /*to*/, uint64 /*fraudImpressionsDelta*/) public onlyChannelContract {
    // To be implemented
  }

  // MODIFIERS

  modifier onlyChannelContract() {
    require(msg.sender == channelContractAddress);
    _;
  }

  // FIELDS

  address channelContractAddress;
}
