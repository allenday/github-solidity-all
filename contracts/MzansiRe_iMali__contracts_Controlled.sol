pragma solidity ^0.4.18;

/**
 * @title Controlled
 * @dev Restricts execution of modified functions to the contract controller alone
 */
contract Controlled {
  address public controller;

  function Controlled() public {
    controller = msg.sender;
  }

  modifier onlyController {
    require(msg.sender == controller);
    _;
  }

  function transferControl(address newController) public onlyController{
    controller = newController;
  }
} 

