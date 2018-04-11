pragma solidity ^0.4.15;

contract LeagueAdministrator {
  address public leagueAdministrator;

  function LeagueAdministrator() {
    leagueAdministrator = msg.sender;
  }

  modifier OnlyLeagueAdministrator() {
    require(msg.sender == leagueAdministrator);
    _;
  }
}

contract League is LeagueAdministrator {
  mapping (address => uint256) public DraftDayToken;

  event Action(address _user, string _nameOfAction);

  function League(address _setAdmin, uint _setTokenAmount) {
    leagueAdministrator = _setAdmin;
    DraftDayToken[leagueAdministrator] = _setTokenAmount;
    Action(_setAdmin, "League Created");
  }

  function AddParticipant(address _Team, uint256 _IssueNumberOfTokens) {
    if ((DraftDayToken[leagueAdministrator] - _IssueNumberOfTokens) > 0) {
      DraftDayToken[_Team] += _IssueNumberOfTokens;
      DraftDayToken[leagueAdministrator] -= _IssueNumberOfTokens;
      Action(_Team, "Added to League");
    }
  }

  function SetDraftOrder() OnlyLeagueAdministrator {
    // Add contents
  }

  function DraftPlayer(address _Team, uint _AmountToPay) {
    // Add contents
  }
}
