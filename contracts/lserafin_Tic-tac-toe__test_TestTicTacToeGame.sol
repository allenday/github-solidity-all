pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TicTacToeGame.sol";

contract TestTicTacToeGame {

  function testInitialBoardUsingDeployedContract() {
    TicTacToeGame game = TicTacToeGame(DeployedAddresses.TicTacToeGame());

    uint returned = game.checkPosition(0,0);
    uint expected = 0;
    
    Assert.equal(returned, expected, "Empty board initially");
  }
  /*
  function testInitialBalanceWithNewMetaCoin() {
    TicTacToeGame game = new TicTacToeGame();

    Assert.equal(game.getBoard()[0][0], 0, "Empty board initially");
  }*/

}
