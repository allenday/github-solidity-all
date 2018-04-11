pragma solidity ^0.4.11;

/*
  Copyright 2017, Jorge Izquierdo (Aragon Foundation)
  Copyright 2017, Jordi Baylina (Giveth)

  Based on MiniMeToken.sol from https://github.com/Giveth/minime
  Original contract from https://github.com/aragon/aragon-network-token/blob/master/contracts/interface/Controlled.sol
*/

import "./Controlled.sol";

contract Burnable is Controlled {
  /// @notice The address of the controller is the only address that can call
  ///  a function with this modifier, also the burner can call but also the
  /// target of the function must be the burner
  modifier onlyControllerOrBurner(address target) {
    assert(msg.sender == controller || (msg.sender == burner && msg.sender == target));
    _;
  }

  modifier onlyBurner {
    assert(msg.sender == burner);
    _;
  }
  address public burner;

  function Burnable() { burner = msg.sender;}

  /// @notice Changes the burner of the contract
  /// @param _newBurner The new burner of the contract
  function changeBurner(address _newBurner) onlyBurner {
    burner = _newBurner;
  }
}
