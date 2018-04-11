/**
 * @title Pay2Play Smart Contract
 * @url http://pay2play.io
 * @version 1.0.0
 */

pragma solidity ^0.4.21;

import './ERC20.sol';

contract Deposit
{
  address public registrar;

  address constant burn = 0xdead;

  uint public creationDate;

  address public owner;
  uint public value;

  bool public active;

  event BalanceTransfered(address winner);

  function Deposit(address _owner) payable public
  {
      owner = _owner;
      registrar = msg.sender;
      creationDate = now;
      active = true;
      value = msg.value;
  }

  modifier onlyRegistrar
  {
      if (msg.sender != registrar) revert();
      _;
  }

  modifier onlyActive
  {
      if (!active) revert();
      _;
  }

  function setRegistrar(address _registrar) onlyRegistrar public
  {
      registrar = _registrar;
  }

  function withdraw(address winner) onlyRegistrar public
  {
    winner.transfer(this.balance);

    value = 0;
    active = false;

    emit BalanceTransfered(winner);
  }

  function getActiveState() returns (bool)
  {
    return active;
  }
}

contract Registrar
{

    uint public registrarStartDate;
    address public node;
    address public tokenNode;
    uint public fee;

    uint32 constant wagerWindow = 24 hours;
    uint constant minPrice = 0.01 ether;

    enum Mode { Open, Closed, Finished, Settled }

    struct wager
    {
        address[] depositors;
        uint createdAt;
        uint amount;
        address winner;
        bytes32 rulesHash;
    }

    wager[] public wagers;
    mapping (address => mapping(uint => Deposit)) public deposits;

    mapping(address => uint) winCount;
    mapping(address => uint) lossCount;

    address[] moderators;

    event WagerStarted(uint indexed index, uint createdAt);
    event NewDeposit(uint indexed index, address indexed owner, uint amount);

    event WagerWinnerUpdated(uint indexed index, address indexed winner);
    event WinningsWithdrawn(uint indexed index, address indexed winner, uint amount);

    event ModeratorListUpdated(address indexed moderator);

    function Registrar(address _tokenNode) public
    {
        registrarStartDate = now;
        node = msg.sender;
        tokenNode = _tokenNode;
    }

    modifier onlyRegistrar
    {
        if (msg.sender != node) revert();
        _;
    }

    modifier onlyWinner(uint index)
    {
        wager w = wagers[index];
        if (msg.sender != w.winner) revert();
        _;
    }

    function state(uint index) constant public returns (Mode)
    {
        var wager = wagers[index];

        if (wager.winner != node)
        {
          var deposit = deposits[wager.winner][index];

          if (deposit.getActiveState() != true)
          {
            return Mode.Settled;
          }

          return Mode.Finished;
        }

        if (wager.depositors.length == 1)
        {
          return Mode.Open;
        }

        if (wager.depositors.length == 2)
        {
          return Mode.Closed;
        }
    }

    function isModerator(address moderator) constant public returns(bool)
    {
      for (uint i = 0; i < moderators.length; i++)
      {
        if (moderators[i] == moderator)
        {
          return true;
        }
      }
      return false;
    }

    modifier inState(uint _index, Mode _state)
    {
        if(state(_index) != _state) revert();
        _;
    }

    function getWager(uint index) constant public returns (Mode, uint, uint, address, address[], bytes32)
    {
        wager w = wagers[index];

        address[] memory owners = new address[](w.depositors.length);

        for (uint i = 0; i < w.depositors.length; i++)
        {
          owners[i] = w.depositors[i];
        }

        return (state(index), w.createdAt, w.amount, w.winner, owners, w.rulesHash);
    }
    
    function getWinCount(address player) constant public returns (uint)
    {
        return winCount[player];
    }

    function getLossCount(address player) constant public returns (uint)
    {
        return lossCount[player];
    }

    function getWagerCount() public constant returns (uint)
    {
        return wagers.length;
    }

    function createWager(bytes32 rulesHash) constant public returns (uint)
    {
        uint index = wagers.length;

        wagers.push(wager(new address[](0), now, 0, node, rulesHash));

        emit WagerStarted(index, now);

        return index;
    }

    function newDeposit(uint index) payable public
    {
        if (msg.value < minPrice) revert();

        if (address(deposits[msg.sender][index]) > 0 ) revert();

        Deposit newDeposit = (new Deposit).value(msg.value)(msg.sender);

        deposits[msg.sender][index] = newDeposit;

        wager w = wagers[index];

        w.depositors.push(msg.sender);

        w.amount = w.amount + msg.value;

        emit NewDeposit(index, msg.sender, msg.value);
    }

    function createWagerAndDeposit(bytes32 rulesHash) payable public
    {
        uint index = createWager(rulesHash);
        newDeposit(index);
    }

    function counterWagerAndDeposit(uint index) payable public
    {
        newDeposit(index);
    }

    function setWagerWinner(uint index, address winner) onlyRegistrar public
    {
      wager w = wagers[index];

      w.winner = winner;

      ERC20Interface(tokenNode).transfer(winner, 1);

      for (uint i = 0; i < w.depositors.length; i++)
      {
        if (w.depositors[i] == winner)
        {
          winCount[winner] += 1;
        }
        else
        {
          lossCount[w.depositors[i]] += 1;
        }
      }

      emit WagerWinnerUpdated(index, winner);
    }

    function withdrawWinnings(uint index) onlyWinner(index) public
    {
      wager w = wagers[index];

      for (uint i = 0; i < w.depositors.length; i++)
      {
        deposits[w.depositors[i]][index].withdraw(w.winner);
      }
      emit WinningsWithdrawn(index, w.winner, w.amount);
    }

    function addModerator(address moderator) onlyRegistrar public
    {
      if (isModerator(moderator) != true)
      {
        moderators.push(moderator);
        emit ModeratorListUpdated(moderator);
      }
    }

    mapping (address => bytes32) public secrets;

    function setSecret(bytes32 _value) public
    {
      secrets[msg.sender] = keccak256(_value);
    }

    function hashValue(bytes32 _value) pure public returns (bytes32)
    {
      return keccak256(_value);
    }

    enum Error { None, Mismatch }

    function getTokenBalance(address _address, bytes32 _value) constant public returns (Error, uint)
    {
      bytes32 secret = hashValue(_value);

      if (secrets[_address] == secret)
      {
        uint balance = ERC20Interface(tokenNode).balanceOf(_address);
        return (Error.None, balance);
      }
      else
      {
        return (Error.Mismatch, 0);
      }
    }
}
