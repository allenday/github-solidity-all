pragma solidity ^0.4.16;

import "utils/Controller.sol";
import "utils/MembershipRegistry.sol";


contract FutarchyOracle {
    function getOutcome() public constant returns (int);
}
contract Token {}
contract Oracle {}
contract MarketFactory {}
contract MarketMaker {}

contract FutarchyOracleFactory {
  function createFutarchyOracle(
    Token collateralToken,
    Oracle oracle,
    uint8 outcomeCount,
    int lowerBound,
    int upperBound,
    MarketFactory marketFactory,
    MarketMaker marketMaker,
    uint24 fee,
    uint deadline)
    public
    returns (FutarchyOracle futarchyOracle);
}

contract FutarchyController is Controller, MembershipRegistry {
    string public constant name = "FutarchyController";
    string public constant version = "1.0";
    FutarchyOracleFactory public factory;
    mapping(uint256 => FutarchyOracle) public oracles;

    function FutarchyController(address _proxy, address[] _members, FutarchyOracleFactory _factory) {
      setProxy(_proxy);
      factory = _factory;
      for (uint256 m = 0; m < _members.length; m++)
        addMember(_members[m]);
    }

    function newProposal(
      string _metadata,
      bytes _data,
      Token collateralToken,
      Oracle oracle,
      uint8 outcomeCount,
      int lowerBound,
      int upperBound,
      MarketFactory marketFactory,
      MarketMaker marketMaker,
      uint24 fee,
      uint deadline)
      public
      payable
      isMoment(numProposals)
      shouldPropose
      returns (uint proposalID) {
        proposalID = numProposals++;
        proposals[proposalID].metadata = _metadata;
        proposals[proposalID].data = _data;

        // new code
        oracles[proposalID] = factory.createFutarchyOracle(
          collateralToken,
          oracle,
          outcomeCount,
          lowerBound,
          upperBound,
          marketFactory,
          marketMaker,
          fee,
          deadline);
    }

    function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
      return isMember(_sender);
    }

    function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
      return isMember(_sender) && oracles[_proposalID].getOutcome() == int(1);
    }

    function votingWeightOf(address _sender, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
      if (isMember(_sender))
        return 1;
    }
}
