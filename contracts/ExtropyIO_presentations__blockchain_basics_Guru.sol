pragma solidity ^0.4.0;
library Oracle{
    function checkNumber(uint256 _guess) constant returns(bool,bool){
        if(_guess==block.number){
            return(true,true);
        }
        else{
            return (false,_guess>block.number);
        }
    }
}

contract Guru{
  mapping(address=>int) balances;
  mapping(address=>string) teamNames;

  address [] teams;

  event teamAwarded(address team,int points);
  event guessOutcome(address team,bool higher);



    function makeGuess(uint256 _guess) internal returns (bool,bool){
      bool correct;
      bool higher;
      (correct,higher) = Oracle.checkNumber(_guess);
      return (correct,higher);
    }


    function submitAnswer(address _submitter,uint256 _answer) external returns (uint8,bool){
    bool correct;
    bool higher;
    (correct,higher) = makeGuess(_answer);
    guessOutcome(tx.origin, higher);
    if(correct){
        balances[_submitter]+=5;
        teamAwarded(_submitter,5);
        return(5,higher);
    }
    else{
        balances[_submitter]-=5;
        teamAwarded(_submitter,-5);
        return(0,higher);
    }

    }


    function addTeam(address _team,string _teamName) external {
        teams.push(_team);
        teamNames[_team] = _teamName;
        balances[_team] = 0;
    }



    function getTeamAddresses() constant external returns (address []){
      return teams;
    }

    function getTeamNameForAddress(address _addr) constant external returns(string){
      return teamNames[_addr];
    }

    function getBalancesForTeam(address _team)constant external returns (int){
      return balances[_team];

    }



}
