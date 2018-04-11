pragma solidity ^0.4.16;

import "MultiSigController.sol";


contract ElectedBoardController is MultiSigController {
  string public constant name = "ElectedBoardController";
  string public constant version = "1.0";

  modifier onlyElectorate { if (msg.sender == electorate) _; }

  function ElectedBoardController(address _proxy, address[] _members, uint256 _required, address _electorate) public {
    for (uint256 m = 0; m < _members.length; m++) {
      addMember(_members[m]);
    }

    electorate = _electorate;
    required = _required;
    setProxy(_proxy);
  }

  function changeVariables(uint256 _required) public onlyElectorate {
    required = _required;
  }

  function changeElectorate(address _electorate) public onlyElectorate {
    electorate = _electorate;
  }

  function addMember(address _member) public onlyElectorate {
    _addMember(_member);
  }

  function removeMember(address _member) public onlyElectorate {
    _removeMember(_member);
  }

  address public electorate;
}
