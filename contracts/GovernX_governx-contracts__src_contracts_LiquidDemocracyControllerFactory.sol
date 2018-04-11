pragma solidity ^0.4.16;

import "utils/Proxy.sol";
import "utils/PrivateServiceRegistry.sol";
import "utils/MiniMeToken.sol";
import "LiquidDemocracyController.sol";


contract IMinimeTokenFactory {
  function createCloneToken(
      address _parent,
      uint256 _snapShotBlock,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol,
      bool _transfersEnabled) public returns (address service);
}

contract MinimeTokenFactory is IMinimeTokenFactory, PrivateServiceRegistry {
  function createCloneToken(
      address _parent,
      uint256 _snapShotBlock,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol,
      bool _transfersEnabled) public returns (address service) {
      service = address(new MiniMeToken(
        address(this),
        _parent,
        _snapShotBlock,
        _tokenName,
        _decimalUnits,
        _tokenSymbol,
        _transfersEnabled));
      register(service);
    }
}

contract LiquidDemocracyControllerFactory is PrivateServiceRegistry {
    IMinimeTokenFactory public factory;

    function LiquidDemocracyControllerFactory(address _tokenFactory) {
      factory = IMinimeTokenFactory(_tokenFactory);
    }

    function createProxy(
      address _token,
      address _curator,
      uint256 _baseQuorum,
      uint256 _debatePeriod,
      uint256 _votingPeriod,
      uint256 _gracePeriod,
      uint256 _executionPeriod,
      address _parent,
      uint256 _snapShotBlock,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol,
      bool _transfersEnabled
      ) public returns (address proxy) {
      proxy = address(new Proxy());

      // create token
      if (_token == address(0))
        _token = factory.createCloneToken(
            _parent,
            _snapShotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled);

      address controller = address(new LiquidDemocracyController(
        proxy,
        _token,
        _curator,
        _baseQuorum,
        _debatePeriod,
        _votingPeriod,
        _gracePeriod,
        _executionPeriod));

      // create controller
      Proxy(proxy).transfer(controller);
      register(proxy);
    }

    function createController(
      address _proxy,
      address _token,
      address _curator,
      uint256 _baseQuorum,
      uint256 _debatePeriod,
      uint256 _votingPeriod,
      uint256 _gracePeriod,
      uint256 _executionPeriod) public returns (address service) {
      service = address(new LiquidDemocracyController(
        _proxy,
        _token,
        _curator,
        _baseQuorum,
        _debatePeriod,
        _votingPeriod,
        _gracePeriod,
        _executionPeriod));
      register(service);
    }
}
