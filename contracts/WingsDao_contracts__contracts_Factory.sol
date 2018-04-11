pragma solidity ^0.4.8;

contract Factory {
  event CONTRACT_INSTANIATION(address indexed creator, address instantiation);

  mapping(address => bool) public isInstantiation;
  mapping(address => address[]) public instantiations;

  address public timeManager;
  address public token;

  function Factory(address _token, address _timeManager) {
    token = _token;
    timeManager = _timeManager;
  }

  /// @dev Returns number of instantiations by creator.
  /// @param creator Contract creator.
  /// @return Returns number of instantiations by creator.
  function getInstantiationCount(address creator)
      public
      constant
      returns (uint)
  {
      return instantiations[creator].length;
  }

  /// @dev Registers contract in factory registry.
  /// @param instantiation Address of contract instantiation.
  function register(address instantiation)
      internal
  {
      isInstantiation[instantiation] = true;
      instantiations[msg.sender].push(instantiation);
      CONTRACT_INSTANIATION(msg.sender, instantiation);
  }
}
