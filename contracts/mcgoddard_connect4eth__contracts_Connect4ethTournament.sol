pragma solidity ^0.4.6; // Specify compiler version

import "./Connect4eth.sol";

contract Connect4ethTournament {
  mapping (address => bytes32) games;
  address[] gameAddresses;
  mapping (address => bytes32) players;
  address[] playerAddresses;
  
  function addGame(bytes32 gameName, address player1, address player2, uint fee) {
    // check listed players are known
    if (players[player1] == bytes32(0x0) || players[player2] == bytes32(0x0)) throw;
    // construct game
    address newGame = new Connect4eth(player1, player2, fee);
    // add game to internal list
    games[newGame] = gameName;
    gameAddresses.push(newGame);
  }
  
  function addPlayer(address player, bytes32 name) {
    if (players[player] != bytes32(0x0)) throw;
    players[player] = name;
    playerAddresses.push(player);
  }
  
  function getPlayerName(address playerAddress) constant returns (bytes32) {
    return players[playerAddress];
  }
  
  function getGameName(address gameAddress) constant returns (bytes32) {
    return games[gameAddress];
  }
  
  function getGames() constant returns (address[]) {
    return gameAddresses;
  }
  
  function getPlayers() constant returns (address[]) {
    return playerAddresses;
  }
}
